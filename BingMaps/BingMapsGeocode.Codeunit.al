codeunit 74120 "BingMaps Geocode"
{
    trigger OnRun();
    var
        Cust: Record Customer;
    begin
        if Cust.FindSet() then
            repeat
                GeocodeCustomer(Cust);
                Commit();
            until Cust.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterModifyEvent', '', true, true)]
    local procedure ModifyCustomer(VAR Rec: Record Customer)
    begin
        GeocodeCustomer(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', true, true)]
    local procedure DeleteCustomer(VAR Rec: Record Customer)
    var
        BingMapsCustomer: Record "BingMaps Customer";
    begin
        if BingMapsCustomer.Get(Rec."No.") then
            BingMapsCustomer.Delete(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterRenameEvent', '', true, true)]
    local procedure RenameCustomer(VAR Rec: Record Customer; VAR xRec: Record Customer)
    var
        BingMapsCustomer: Record "BingMaps Customer";
    begin
        if BingMapsCustomer.Get(xRec."No.") then
            BingMapsCustomer.Rename(Rec."No.");
    end;

    procedure GeocodeCustomer(Customer: Record Customer)
    var
        BingMapsCustomer: Record "BingMaps Customer";
        ErrorText: Text;
    begin
        if not BingMapsCustomer.Get(Customer."No.") then begin
            BingMapsCustomer.Init();
            BingMapsCustomer."No." := Customer."No.";
            BingMapsCustomer.Insert();
        end;
        GeocodeCustomer(Customer, BingMapsCustomer, ErrorText);
        BingMapsCustomer.Modify();
    end;

    procedure GeocodeCustomer(Customer: Record Customer; var BingMapsCustomer: Record "BingMaps Customer"; var ErrorText: Text): Boolean
    var
        Country: Record "Country/Region";
        BingMapsGeocode: Codeunit "BingMaps Geocode";
        CountryName: Text;
        Address: Text;
    begin
        CountryName := Customer."Country/Region Code";
        if Country.GET(CountryName) then
            CountryName := Country.Name;
        Address := Customer.Address + ' ' + Customer."Address 2" + ' ' + Customer.City + ' ' + CountryName;
        if BingMapsCustomer.Address <> Address then begin
            BingMapsCustomer.Geocoded := 0;
            if BingMapsGeocode.Geocode(Address, BingMapsCustomer.Latitude, BingMapsCustomer.Longitude, ErrorText) then begin
                // Full address geocoded
                BingMapsCustomer.Zoom := 15;
                BingMapsCustomer.Geocoded := 1;
                bingMapsCustomer.Address := Address;
                exit(true);
            end else begin
                if BingMapsGeocode.Geocode(Customer.City + ' ' + CountryName, BingMapsCustomer.Latitude, BingMapsCustomer.Longitude, ErrorText) then begin
                    // City and country geocoded
                    BingMapsCustomer.Zoom := 9;
                    BingMapsCustomer.Geocoded := 1;
                    bingMapsCustomer.Address := Address;
                    exit(true);
                end else begin
                    // Geocoding not possible
                    BingMapsCustomer.Latitude := 0;
                    BingMapsCustomer.Longitude := 0;
                    BingMapsCustomer.Zoom := 0;
                    BingMapsCustomer.Geocoded := -1;
                    bingMapsCustomer.Address := '';
                    exit(false);
                end;
            end;
        end;
        exit(false);
    end;

    procedure Geocode(BingMapsQuery: Text; var Latitude: Decimal; var Longitude: Decimal; var ErrorText: Text): Boolean
    var
        BingMapsSettings: Record "BingMaps Settings";
        BingMapsKey: Text;
        Url: Text;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        Result: Text;
        ResContent: JsonObject;
        EstimatedTotalToken: JsonToken;
        LatitudeToken: JsonToken;
        LongitudeToken: JsonToken;
        Ok: Boolean;
    begin
        if not BingMapsSettings.FindFirst() then begin
            ErrorText := 'BingMaps Integration not properly setup';
            exit(false);
        end;
        ErrorText := '';
        BingMapsKey := BingMapsSettings."BingMaps Key";
        if BingMapsKey = '' then begin
            ErrorText := 'BingMaps Key not defined';
            exit(false);
        end;
        if BingMapsKey = 'Test' then
            Result := '{"authenticationResultCode":"ValidCredentials","brandLogoUri":"http:\/\/dev.virtualearth.net\/Branding\/logo_powered_by.png","copyright":"Copyright © 2020 Microsoft and its suppliers. All rights reserved. This API cannot be accessed and the content and any results may not be used, reproduced or transmitted in any manner without express written permission from Microsoft Corporation.","resourceSets":[{"estimatedTotal":1,"resources":[{"__type":"Location:http:\/\/schemas.microsoft.com\/search\/local\/ws\/rest\/v1","bbox":[47.6381299,-122.13309,47.64252,-122.13005],"name":"Microsoft Way, Redmond, WA 98052, United States","point":{"type":"Point","coordinates":[47.64045,-122.13079]},"address":{"addressLine":"Microsoft Way","adminDistrict":"WA","adminDistrict2":"King Co.","countryRegion":"United States","formattedAddress":"Microsoft Way, Redmond, WA 98052, United States","locality":"Redmond","postalCode":"98052"},"confidence":"High","entityType":"RoadBlock","geocodePoints":[{"type":"Point","coordinates":[47.64045,-122.13079],"calculationMethod":"Interpolation","usageTypes":["Display"]},{"type":"Point","coordinates":[47.64045,-122.13079],"calculationMethod":"Interpolation","usageTypes":["Route"]}],"matchCodes":["Good"]}]}],"statusCode":200,"statusDescription":"OK","traceId":"62b12d317c1243c8a0141d3dd7de473e|DU00000B74|0.0.0.1|Ref A: 1537374449DC4314BCE8ABD2417467D5 Ref B: DB3EDGE0912 Ref C: 2020-01-17T10:32:16Z"}'
        else begin
            Url := 'https://dev.virtualearth.net/REST/v1/Locations?q=' + BingMapsQuery + '&o=json&key=' + BingMapsKey;
            Ok := Client.Get(Url, ResponseMessage);
            if (not OK) or (not ResponseMessage.IsSuccessStatusCode()) then begin
                ErrorText := 'Error connecting to Web Service ' + Url;
                EXIT(false);
            end;
            ResponseMessage.Content().ReadAs(Result);
        end;
        if not ResContent.ReadFrom(Result) then begin
            ErrorText := 'Invalid response from Web Service';
            EXIT(false);
        end;
        if not ResContent.SelectToken('resourceSets[0].estimatedTotal', EstimatedTotalToken) then begin
            ErrorText := 'Could not geocode address, estimatedTotal is missing';
            EXIT(false);
        end;
        if EstimatedTotalToken.AsValue().AsInteger() = 0 then begin
            ErrorText := 'Could not geocode address, estimatedTotal is 0';
            EXIT(false);
        end;
        if (not ResContent.SelectToken('resourceSets[0].resources[0].point.coordinates[0]', LatitudeToken)) or
           (not ResContent.SelectToken('resourceSets[0].resources[0].point.coordinates[1]', LongitudeToken)) then begin
            ErrorText := 'Could not geocode address, coordinates is missing';
            EXIT(false);
        end;
        Latitude := LatitudeToken.AsValue().AsDecimal();
        Longitude := LongitudeToken.AsValue().AsDecimal();
        EXIT(true);
    end;
}
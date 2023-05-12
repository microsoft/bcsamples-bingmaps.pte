page 74124 "BingMaps Customer"
{
    PageType = API;
    Caption = 'BingMaps Customer Location';
    APIPublisher = 'microsoft';
    APIGroup = 'bingmaps';
    APIVersion = 'v1.0';
    EntityName = 'customer';
    EntitySetName = 'customer';
    SourceTable = Customer;
    DelayedInsert = true;
    SourceTableTemporary = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(no; Rec."no.")
                {
                    ApplicationArea = All;
                }
                field(name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(city; Rec.City)
                {
                    ApplicationArea = All;
                }
                field(country; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(phone; Rec."Phone No.")
                {
                    ApplicationArea = All;
                }
                field(geocoded; geocoded)
                {
                    ApplicationArea = All;
                }
                field(latitude; latitude)
                {
                    ApplicationArea = All;
                }
                field(longitude; longitude)
                {
                    ApplicationArea = All;
                }
                field(url; url)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        URL: Text;
        Geocoded: Integer;
        Latitude: Decimal;
        Longitude: Decimal;

    trigger OnAfterGetRecord()
    var
        BingMapsCustomer: Record "BingMaps Customer";
    begin
        URL := GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Customer Card", Rec);
        if BingMapsCustomer.Get(Rec."No.") then begin
            Geocoded := BingMapsCustomer.Geocoded;
            Latitude := BingMapsCustomer.Latitude;
            Longitude := BingMapsCustomer.Longitude;
        end else begin
            Geocoded := 0;
            Latitude := 0;
            Longitude := 0;
        end;
    end;
}
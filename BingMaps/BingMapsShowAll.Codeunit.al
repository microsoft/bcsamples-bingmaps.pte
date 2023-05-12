codeunit 74122 "BingMaps Show All"
{
    trigger OnRun()
    var
        BingMapsSettings: Record "BingMaps Settings";
        BingMapsSetup: Codeunit "BingMaps Setup";
        wsUserOk: Boolean;
    begin
        if (BingMapsSetup.GetSettings(BingMapsSettings, wsUserOk) and wsUserOk) then
            hyperlink('https://bingmapsintegration.azurewebsites.net/Default.aspx?username=' + BingMapsSettings."Bingmaps WS Username" + '&publicodatabaseurl=' + GETURL(ClientType::OData) + '&bingmapskey=' + Escape(BingMapsSettings."BingMaps Key") + '&wskey=' + Escape(BingMapsSettings."BingMaps WS Key"));
    end;

    procedure Escape(t: Text) Result: Text
    var
        i: Integer;
        b: byte;
        digits: Text[16];
    begin
        digits := '0123456789ABCDEF';
        for i := 1 to StrLen(t) do begin
            b := t[i];
            Result := Result + '%' + digits[(b - b mod 16) / 16 + 1] + digits[b mod 16 + 1];
        end;
    end;
}
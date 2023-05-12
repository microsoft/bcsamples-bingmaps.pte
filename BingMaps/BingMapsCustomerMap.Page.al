page 74121 "BingMaps CustomerMap"
{
    PageType = CardPart;
    SourceTable = "BingMaps Customer";
    Caption = 'Customer Map';

    layout
    {
        area(content)
        {
            field("No."; Rec."No.")
            {
                ApplicationArea = All;
                Visible = noIsVisible;
                Tooltip = 'Customer no.';
            }

            usercontrol(Map; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = All;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    mapIsReady := true;
                    UpdateMap();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if mapIsReady then
            UpdateMap();
    end;

    procedure UpdateMap()
    var
        Customer: Record Customer;
        latitudeStr: Text;
        longitudeStr: Text;
        zoomStr: Text;
        embedUrl: Text;
        largeMapUrl: Text;
        directionsUrl: Text;
    begin
        if Customer.GET(Rec."No.") then begin
            latitudeStr := FORMAT(Rec.Latitude, 0, 9);
            longitudeStr := FORMAT(Rec.Longitude, 0, 9);
            zoomStr := FORMAT(Rec.Zoom);
            embedUrl := 'https://www.bing.com/maps/embed?h=280&w=310&cp=' + LatitudeStr + '~' + longitudeStr + '&typ=d&sty=r&lvl=' + zoomStr;
            largeMapUrl := 'https://www.bing.com/maps?cp=' + latitudeStr + '~' + longitudeStr + '&amp;sty=r&amp;lvl=' + zoomStr + '&amp;sp=point.' + latitudeStr + '_' + longitudeStr + '_' + Customer.Name;
            directionsUrl := 'https://www.bing.com/maps/directions?cp=' + latitudeStr + '~' + longitudeStr + '&amp;sty=r&amp;lvl=' + zoomStr + '&amp;rtp=~pos.' + latitudeStr + '_' + longitudeStr;
            CurrPage.Map.SetContent('<div><iframe width="310" height="280" frameborder="1" src="' + embedUrl + '" scrolling="no"></iframe><div style="white-space: nowrap; text-align: center; width: 310px; padding: 6px 0;"><a target="_blank" style="text-decoration: none" href="' + largeMapUrl + '">View Larger Map</a> &nbsp; | &nbsp;<a target="_blank" style="text-decoration: none" href="' + directionsUrl + '">Get Directions</a></div></div>');
        end;
    end;

    var
        mapIsReady: Boolean;
        noIsVisible: Boolean;
}
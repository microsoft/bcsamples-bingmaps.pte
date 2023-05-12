pageextension 74123 "BingMaps Cust List" extends "Customer List"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part("BingMaps CustomerMap"; "BingMaps CustomerMap")
            {
                ApplicationArea = All;
                SubPageLink = "No." = FIELD("No.");
                Caption = 'Customer Map';
                Visible = ShowFactBox;
            }
        }
    }

    actions
    {
        addfirst("&Customer")
        {
            action("BingMaps ShowAll")
            {
                Caption = 'Show All Customers on Bing Maps';
                ApplicationArea = All;
                Image = Map;
                Enabled = EnableShowAll;
                ToolTip = 'Open a web page, showing all customers on a map';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                RunObject = codeunit "BingMaps Show All";
            }
        }
    }

    var
        EnableShowAll: Boolean;
        ShowFactBox: Boolean;

    trigger OnOpenPage()
    var
        BingMapsSettings: Record "BingMaps Settings";
        BingMapsSetup: Codeunit "BingMaps Setup";
    begin
        ShowFactBox := BingMapsSetup.GetSettings(BingMapsSettings, EnableShowAll);
    end;
}
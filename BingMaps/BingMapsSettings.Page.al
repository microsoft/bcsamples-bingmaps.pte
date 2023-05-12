page 74125 "BingMaps Settings"
{
    PageType = API;
    Caption = 'BingMaps Settings';
    APIPublisher = 'microsoft';
    APIGroup = 'bingmaps';
    APIVersion = 'v1.0';
    EntityName = 'settings';
    EntitySetName = 'settings';
    SourceTable = "Name/Value Buffer";
    DelayedInsert = true;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(bingmapsKeyid; Rec.ID)
                {
                    ApplicationArea = All;
                }

                field(name; Rec.Name)
                {
                    ApplicationArea = All;
                }

                field(value; Rec."Value")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        BingMapsSettings: Record "BingMaps Settings";
        BingMapsSetup: Codeunit "BingMaps Setup";
        sessionId: Integer;
        ErrorText: Text;
    begin
        case Rec.Name of
            'BingMapsKey':
                begin
                    if not BingMapsSettings.WritePermission() then
                        ERROR('User does not have permissions to write to the settings table.');
                    BingMapsSetup.GetSettings(BingMapsSettings);
                    BingMapsSettings."BingMaps Key" := COPYSTR(Rec."Value", 0, 80);
                    BingMapsSettings.Modify();
                    if not BingMapsSetup.TestSettings(BingMapsSettings, ErrorText) then
                        ERROR(ErrorText);
                    BingMapsSettings."BingMaps Key OK" := true;
                    BingMapsSettings.Modify();
                    Commit();
                    StartSession(sessionId, Codeunit::"BingMaps Geocode");
                end;
        end;
    end;

}

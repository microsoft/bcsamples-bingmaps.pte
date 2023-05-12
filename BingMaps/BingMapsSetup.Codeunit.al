codeunit 74123 "BingMaps Setup"
{
    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', true, true)]
    local procedure RegisterServiceConnection(Var ServiceConnection: Record "Service Connection")
    var
        BingMapsSettings: Record "BingMaps Settings";
        BingMapsSetup: Codeunit "BingMaps Setup";
        RecRef: RecordRef;
    begin
        if not BingMapsSettings.WritePermission() then
            exit;
        BingMapsSetup.GetSettings(BingMapsSettings);
        RecRef.GETTABLE(BingMapsSettings);
        ServiceConnection.Status := ServiceConnection.Status::Disabled;
        IF BingMapsSettings."BingMaps Key OK" THEN
            ServiceConnection.Status := ServiceConnection.Status::Enabled;
        ServiceConnection.InsertServiceConnection(ServiceConnection, RecRef.RecordId(), 'BingMaps Integration Setup', '', PAGE::"BingMaps Setup");
    end;

    procedure TestSettings(var BingMapsSettings: record "BingMaps Settings"; var ErrorText: Text): Boolean;
    var
        tempCustomer: Record Customer temporary;
        tempBingMapsCustomer: Record "BingMaps Customer" temporary;
        BingMapsGeocode: Codeunit "BingMaps Geocode";
    begin
        if BingMapsSettings."BingMaps Key" = '' then begin
            ErrorText := 'BingMaps Key not defined';
            exit(false);
        end;
        tempCustomer.Init();
        tempCustomer.Name := 'Microsoft';
        tempCustomer.Address := 'One Microsoft Way';
        tempCustomer."Country/Region Code" := 'US';
        tempCustomer.City := 'Redmond';
        tempBingMapsCustomer.Init();
        if BingMapsGeocode.GeocodeCustomer(tempCustomer, tempBingMapsCustomer, ErrorText) then begin
            BingMapsSettings."BingMaps Key OK" := true;
            Exit(true);
        end;
        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Conf./Personalization Mgt.", 'OnRoleCenterOpen', '', true, true)]
    local procedure CheckSubscriptionStatus_OnOpenRoleCenter()
    var
        BingMapsSettings: Record "BingMaps Settings";
        BingMapsSetup: Codeunit "BingMaps Setup";
        MyNotification: Notification;
    begin
        if not BingMapsSettings.WritePermission() then
            exit;
        if not BingMapsSetup.GetSettings(BingMapsSettings) then begin
            MyNotification.Id('3EBC1525-C2D4-4797-8B28-BA2D0C6294B5');
            MyNotification.Scope(NotificationScope::LocalScope);
            MyNotification.Message('BingMaps Integration is missing some settings to work properly');
            MyNotification.AddAction('Setup BingMaps Integration', CODEUNIT::"BingMaps Setup", 'SetupBingMapsIntegration');
            MyNotification.Send();
        end;
    end;

    procedure SetupBingMapsIntegration(notification: Notification);
    var
        BingMapsSetup: Page "BingMaps Setup";
    begin
        BingMapsSetup.RunModal();
    end;

    procedure GetSettings(var BingMapsSettings: Record "BingMaps Settings"): Boolean
    begin
        if not BingMapsSettings.FindFirst() then begin
            if not BingMapsSettings.WritePermission() then
                exit(false);
            BingMapsSettings.Init();
            BingMapsSettings.Insert();
        end;
        exit(BingMapsSettings."BingMaps Key OK");
    end;

    procedure GetSettings(var BingMapsSettings: Record "BingMaps Settings"; var WsUserSet: Boolean): Boolean
    begin
        if (not GetSettings(BingMapsSettings)) then
            exit(false);
        WsUserSet := (BingMapsSettings."BingMaps WS Username" <> '') and (BingMapsSettings."BingMaps WS Key" <> '');
        exit(true);
    end;

}
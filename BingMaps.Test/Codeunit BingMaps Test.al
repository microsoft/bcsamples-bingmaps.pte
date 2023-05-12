codeunit 70131 "BingMaps Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        SetupBingMapsMessageOK: Boolean;
        ShowAllHyperlinkOK: Boolean;
        RoleCenterNotificationOK: Boolean;

    trigger OnRun()
    var
        BingMapsSetup: Record "BingMaps Settings";
    begin
        BingMapsSetup.DeleteAll();
    end;

    [Test]
    [HandlerFunctions('RoleCenterBingMapsNotificationHandler')]
    procedure RoleCenterNotification()
    var
        roleCenter: TestPage "Order Processor Role Center";
    begin
        roleCenter.OpenView();
        Assert.IsTrue(RoleCenterNotificationOK, 'RoleCenter Notification wasn''t raised when opening the RoleCenter');
        roleCenter.Close();
    end;

    [Test]
    procedure ServiceConnection();
    var
        ServiceConnections: TestPage "Service Connections";
        ServiceConnectionOK: Boolean;
    begin
        ServiceConnections.OpenView();
        if (ServiceConnections.First()) then begin
            repeat
                if (ServiceConnections.Name.Value = 'BingMaps Integration Setup') then ServiceConnectionOK := true;
            until not ServiceConnections.Next();
        end;
        Assert.IsTrue(ServiceConnectionOK, 'Service Connection hasn''t been registered correctly');
        ServiceConnections.Close();
    end;

    [Test]
    [HandlerFunctions('SetupBingMapsMessageHandler')]
    procedure SetupBingMaps();
    var
        BingMapsSetup: TestPage "BingMaps Setup";
        BingMapsGeocode: Codeunit "BingMaps Geocode";
    begin
        BingMapsSetup.OpenEdit();
        Assert.IsFalse(BingMapsSetup."BingMaps Key OK".AsBoolean(), 'BingMaps Key OK should not be set by default');
        BingMapsSetup."BingMaps Key".SetValue('Test');
        Assert.IsFalse(BingMapsSetup."BingMaps Key OK".AsBoolean(), 'BingMaps Key OK should not be set before tested');
        BingMapsSetup.TestBingMapsKey.Invoke();
        Assert.IsTrue(SetupBingMapsMessageOK, 'BingMaps Test message did not appear as expected');
        Assert.IsTrue(BingMapsSetup."BingMaps Key OK".AsBoolean(), 'BingMaps Key OK should be true after testing BingMaps Key');
        BingMapsGeocode.Run();
        BingMapsSetup."Web Services Username".SetValue('Username');
        BingMapsSetup."Web Services Key".SetValue('Key');
    end;

    [Test]
    procedure CreateCustomer();
    var
        Customer: Record "Customer";
        BingMapsCustomer: Record "BingMaps Customer";
    begin
        Customer.Init();
        Customer."No." := 'freddyk';
        Customer.Insert();
        Customer.Name := 'Freddy Kristiansen';
        Customer.Modify();
        Assert.IsTrue(BingMapsCustomer.Get('freddyk'), 'Geocode record wasn''t created');
    end;

    [Test]
    procedure RenameCustomer();
    var
        Customer: Record "Customer";
        BingMapsCustomer: Record "BingMaps Customer";
    begin
        Customer.Get('freddyk');
        Customer.Rename('freddydk');
        Assert.IsFalse(BingMapsCustomer.Get('freddyk'), 'Geocode record wasn''t renamed');
        Assert.IsTrue(BingMapsCustomer.Get('freddydk'), 'Geocode record wasn''t renamed');
    end;

    [Test]
    procedure DeleteCustomer();
    var
        Customer: Record "Customer";
        BingMapsCustomer: Record "BingMaps Customer";
    begin
        Customer.Get('freddydk');
        Customer.Delete();
        Assert.IsFalse(BingMapsCustomer.Get('freddydk'), 'Geocode record wasn''t removed');
    end;

    [Test]
    procedure BingMapsOnCustomerCard();
    var
        CustomerCard: TestPage "Customer Card";
        CustomerMap: TestPage "BingMaps CustomerMap";
        Customer: Record Customer;
        BingMapsCustomer: Record "BingMaps Customer";
    begin
        Customer.FindLast();
        CustomerCard.OpenView();
        CustomerCard.GoToRecord(Customer);
        Assert.AreEqual(Customer."No.", CustomerCard."BingMaps CustomerMap"."No.".Value, 'Factbox is not bound on Customer Card');
        CustomerCard.Close();
    end;

    [Test]
    procedure BingMapsOnCustomerList();
    var
        CustomerList: TestPage "Customer List";
        CustomerMap: TestPage "BingMaps CustomerMap";
        Customer: Record Customer;
    begin
        Customer.FindLast();
        CustomerList.OpenView();
        CustomerList.GoToRecord(Customer);
        Assert.AreEqual(Customer."No.", CustomerList."BingMaps CustomerMap"."No.".Value, 'Factbox is not bound on Customer List');
        CustomerList.Close();
    end;

    [Test]
    [HandlerFunctions('BingMapsShowAllHyperlinkHandler')]
    procedure BingMapsShowAllOnCustomerCard();
    var
        CustomerCard: TestPage "Customer Card";
        CustomerMap: TestPage "BingMaps CustomerMap";
        Customer: Record Customer;
    begin
        ShowAllHyperlinkOK := false;
        Customer.FindFirst();
        CustomerCard.OpenView();
        CustomerCard.GoToRecord(Customer);
        CustomerCard."BingMaps ShowAll".Invoke();
        Assert.IsTrue(ShowAllHyperlinkOK, 'Wrong Hyperlink when pressing Show All on Customer Card');
    end;

    [Test]
    [HandlerFunctions('BingMapsShowAllHyperlinkHandler')]
    procedure BingMapsShowAllOnCustomerList();
    var
        CustomerList: TestPage "Customer List";
        CustomerMap: TestPage "BingMaps CustomerMap";
        Customer: Record Customer;
    begin
        ShowAllHyperlinkOK := false;
        Customer.FindFirst();
        CustomerList.OpenView();
        CustomerList.GoToRecord(Customer);
        CustomerList."BingMaps ShowAll".Invoke();
        Assert.IsTrue(ShowAllHyperlinkOK, 'Wrong Hyperlink when pressing Show All on Customer List');
    end;

    [HyperlinkHandler]
    procedure BingMapsShowAllHyperlinkHandler(Message: Text[1024])
    begin
        ShowAllHyperLinkOK := Message = 'https://bingmapsintegration.azurewebsites.net/Default.aspx?username=Username&publicodatabaseurl=' + GETURL(ClientType::OData) + '&bingmapskey=%54%65%73%74&wskey=%4B%65%79';
    end;

    [MessageHandler]
    procedure SetupBingMapsMessageHandler(Message: Text[1024])
    begin
        SetupBingMapsMessageOK := Message = 'BingMaps Key has been tested and is OK';
    end;

    [SendNotificationHandler]
    procedure RoleCenterBingMapsNotificationHandler(var Notification: Notification): Boolean
    begin
        RoleCenterNotificationOK := (Notification.ID = '3EBC1525-C2D4-4797-8B28-BA2D0C6294B5');
    end;


}
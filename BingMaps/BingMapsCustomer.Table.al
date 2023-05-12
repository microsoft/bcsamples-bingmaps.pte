table 74120 "BingMaps Customer"
{
    fields
    {
        field(74120; "No."; Code[20])
        {
            DataClassification = CustomerContent;
        }

        field(74121; "Geocoded"; Integer)
        {
            DataClassification = CustomerContent;
        }

        field(74122; "Latitude"; Decimal)
        {
            DecimalPlaces = 3 : 5;
            DataClassification = EndUserIdentifiableInformation;
        }

        field(74123; "Longitude"; Decimal)
        {
            DecimalPlaces = 3 : 5;
            DataClassification = EndUserIdentifiableInformation;
        }

        field(74124; "Zoom"; Integer)
        {
            DataClassification = CustomerContent;
        }

        field(74125; "Address"; Text[200])
        {
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key("No."; "No.")
        {
        }

        key("Latitude"; "Latitude")
        {

        }

        key("Longitude"; "Longitude")
        {
        }
    }
}
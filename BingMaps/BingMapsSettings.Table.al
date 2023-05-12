table 74122 "BingMaps Settings"
{
    // version BingMaps


    fields
    {
        field(74120; "BingMaps PK"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(74121; "BingMaps Key"; Text[80])
        {
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "BingMaps Key OK" := false;
            end;
        }
        field(74122; "BingMaps Key OK"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(74123; "BingMaps WS Username"; Text[40])
        {
            DataClassification = SystemMetadata;
        }
        field(74124; "BingMaps WS Key"; Text[80])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key("BingMaps PK"; "BingMaps PK")
        {
        }
    }

    fieldgroups
    {
    }
}


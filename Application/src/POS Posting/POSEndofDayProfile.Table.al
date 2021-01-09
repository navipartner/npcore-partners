table 6150652 "NPR POS End of Day Profile"
{
    Caption = 'POS End of Day Profile';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS End of Day Profiles";
    LookupPageID = "NPR POS End of Day Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "End of Day Type"; Option)
        {
            Caption = 'End of Day Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Individual,Master & Slave';
            OptionMembers = INDIVIDUAL,MASTER_SLAVE;

            trigger OnValidate()
            var
                POSUnit: Record "NPR POS Unit";
            begin

                if ("End of Day Type" = "End of Day Type"::MASTER_SLAVE) then begin
                    TestField("Master POS Unit No.");

                    POSUnit.Get("Master POS Unit No.");
                    if (POSUnit."POS End of Day Profile" <> Rec.Code) then
                        Error(PROFILE_MISSMATCH);
                end;
            end;
        }
        field(21; "Master POS Unit No."; Code[10])
        {
            Caption = 'Master POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(30; "Z-Report UI"; Option)
        {
            Caption = 'Z-Report UI';
            DataClassification = CustomerContent;
            OptionCaption = 'Summary+Balancing,Balancing Only';
            OptionMembers = SUMMARY_BALANCING,BALANCING;
        }
        field(35; "X-Report UI"; Option)
        {
            Caption = 'X-Report UI';
            DataClassification = CustomerContent;
            OptionCaption = 'Summary+Printing,Printing Only';
            OptionMembers = SUMMARY_PRINT,PRINT;
        }
        field(36; "Close Workshift UI"; Option)
        {
            Caption = 'Close Workshift UI';
            DataClassification = CustomerContent;
            OptionCaption = 'Print,No print';
            OptionMembers = PRINT,NO_PRINT;
        }
        field(40; "Force Blind Counting"; Boolean)
        {
            Caption = 'Force Blind Counting';
            DataClassification = CustomerContent;
        }
        field(41; "SMS Profile"; Code[20])
        {
            Caption = 'SMS Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
            TableRelation = "NPR SMS Template Header";
        }
        field(50; "Z-Report Number Series"; Code[10])
        {
            Caption = 'Z-Report Number Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(51; "X-Report Number Series"; Code[10])
        {
            Caption = 'X-Report Number Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(60; "Show Zero Amount Lines"; Boolean)
        {
            Caption = 'Show Zero Amount Lines';
            DataClassification = CustomerContent;
        }
        field(70; "Posting Error Handling"; Option)
        {
            Caption = 'Posting Error Handling';
            DataClassification = CustomerContent;
            OptionCaption = 'With Message,With Error,Silent';
            OptionMembers = WITH_MESSAGE,WITH_ERROR,SILENT;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        PROFILE_MISSMATCH: Label 'The master POS Unit must have the same profile as this unit.';
}


table 6150652 "POS End of Day Profile"
{
    // NPR5.49/TSA /20190314 CASE 348458 Initial Version
    // NPR5.52/SARA/20190823 CASE 363578 New field 'SMS Profile'

    Caption = 'POS End of Day Profile';
    DrillDownPageID = "POS End of Day Profiles";
    LookupPageID = "POS End of Day Profiles";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(10;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(20;"End of Day Type";Option)
        {
            Caption = 'End of Day Type';
            OptionCaption = 'Individual,Master & Slave';
            OptionMembers = INDIVIDUAL,MASTER_SLAVE;

            trigger OnValidate()
            var
                POSUnit: Record "POS Unit";
            begin

                if ("End of Day Type" = "End of Day Type"::MASTER_SLAVE) then begin
                  TestField ("Master POS Unit No.");

                  POSUnit.Get ("Master POS Unit No.");
                  if (POSUnit."POS End of Day Profile" <> Rec.Code) then
                    Error (PROFILE_MISSMATCH);
                end;
            end;
        }
        field(21;"Master POS Unit No.";Code[10])
        {
            Caption = 'Master POS Unit No.';
            TableRelation = "POS Unit";
        }
        field(30;"Z-Report UI";Option)
        {
            Caption = 'Z-Report UI';
            OptionCaption = 'Summary+Balancing,Balancing Only';
            OptionMembers = SUMMARY_BALANCING,BALANCING;
        }
        field(35;"X-Report UI";Option)
        {
            Caption = 'X-Report UI';
            OptionCaption = 'Summary+Printing,Printing Only';
            OptionMembers = SUMMARY_PRINT,PRINT;
        }
        field(36;"Close Workshift UI";Option)
        {
            Caption = 'Close Workshift UI';
            OptionCaption = 'Print,No print';
            OptionMembers = PRINT,NO_PRINT;
        }
        field(40;"Force Blind Counting";Boolean)
        {
            Caption = 'Force Blind Counting';
        }
        field(41;"SMS Profile";Code[20])
        {
            Caption = 'SMS Profile';
            Description = 'NPR5.52';
            TableRelation = "SMS Template Header";
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        PROFILE_MISSMATCH: Label 'The master POS Unit must have the same profile as this unit.';
}


tableextension 6014430 "NPR Jobs Setup" extends "Jobs Setup"
{
    fields
    {
        field(6060150; "NPR Auto. Create Job Task Line"; Boolean)
        {
            Caption = 'Auto. Create Job Task Line';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
        }
        field(6060151; "NPR Def. Job Task No."; Code[20])
        {
            Caption = 'Def. Job Task No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
        }
        field(6060152; "NPR Def. Job Task Description"; Text[50])
        {
            Caption = 'Def. Job Task Description';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
        }
        field(6060153; "NPR Time Calc. Unit of Measure"; Code[10])
        {
            Caption = 'Time Calc. Unit of Measure';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
            TableRelation = "Unit of Measure";
        }
        field(6060154; "NPR Qty. Rel. 2 Start/End Time"; Boolean)
        {
            Caption = 'Qty. Relates to Start/End Time';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
        }
        field(6060155; "NPR Over Capacitate Resource"; Enum "NPR Over Capacitate Resource")
        {
            Caption = 'Over Capacitate Resource';
            DataClassification = CustomerContent;
            Description = 'NPR5.32';
        }
        field(6060156; "NPR Post Event on S.Inv. Post"; Enum "NPR Post Event on S.Inv. Post")
        {
            Caption = 'Post Event on Sales Inv. Post';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
        }
        field(6060157; "NPR Block Event Deletion"; BLOB)
        {
            Caption = 'Block Event Deletion';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }
    }
}
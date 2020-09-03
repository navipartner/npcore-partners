tableextension 6014430 "NPR Jobs Setup" extends "Jobs Setup"
{
    // NPR5.29/TJ/20161014 CASE 248723 New fields 6060150..6060163
    // NPR5.32/TJ/20170515 CASE 275946 New field "Organizer Exchange Url"
    // NPR5.32/TJ/20170519 CASE 275966 Changed name and type of field 6060155 from Resource Availability Warning, Boolean to Over Capacitate Resource, Option
    // NPR5.32/TJ/20170525 CASE 275953 New field "Appointment Lasts Whole Day"
    // NPR5.34/TJ/20170728 CASE 277938 Removed fields 6060158..6060163
    // NPR5.38/TJ/20171027 CASE 285194 Removed field 6060156,6060157 and 6060164
    // NPR5.48/TJ/20181119 CASE 287903 New field "Post Event on Sales Inv. Post"
    // NPR5.53/TJ/20200109 CASE 346821 New field "Block Event Deletion"
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
        field(6060155; "NPR Over Capacitate Resource"; Option)
        {
            Caption = 'Over Capacitate Resource';
            DataClassification = CustomerContent;
            Description = 'NPR5.32';
            OptionCaption = ' ,Allow,Warn,Disallow';
            OptionMembers = " ",Allow,Warn,Disallow;
        }
        field(6060156; "NPR Post Event on S.Inv. Post"; Option)
        {
            Caption = 'Post Event on Sales Inv. Post';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            OptionCaption = ' ,Only Inventory,Both Inventory and Job';
            OptionMembers = " ","Only Inventory","Both Inventory and Job";
        }
        field(6060157; "NPR Block Event Deletion"; BLOB)
        {
            Caption = 'Block Event Deletion';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }
    }
}


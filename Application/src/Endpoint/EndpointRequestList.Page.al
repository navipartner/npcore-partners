page 6014678 "NPR Endpoint Request List"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created
    // NPR5.25\BR\20160801  CASE 234602 Added Query fields

    Caption = 'Endpoint Request List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Endpoint Request";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Endpoint Code"; Rec."Endpoint Code")
                {

                    ToolTip = 'Specifies the value of the Endpoint Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Request Batch No."; Rec."Request Batch No.")
                {

                    ToolTip = 'Specifies the value of the Request Batch No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Type of Change"; Rec."Type of Change")
                {

                    ToolTip = 'Specifies the value of the Type of Change field';
                    ApplicationArea = NPRRetail;
                }
                field("Record ID"; Rec."Record ID")
                {

                    ToolTip = 'Specifies the value of the Record ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Obsolete; Rec.Obsolete)
                {

                    ToolTip = 'Specifies the value of the Obsolete field';
                    ApplicationArea = NPRRetail;
                }
                field("Data log Record No."; Rec."Data log Record No.")
                {

                    ToolTip = 'Specifies the value of the Data log Record No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Query No."; Rec."Query No.")
                {

                    ToolTip = 'Specifies the value of the Query No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("PK Code 1"; Rec."PK Code 1")
                {

                    ToolTip = 'Specifies the value of the Primary Key Code 1 field';
                    ApplicationArea = NPRRetail;
                }
                field("PK Code 2"; Rec."PK Code 2")
                {

                    ToolTip = 'Specifies the value of the Primary Key Code 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("PK Line 1"; Rec."PK Line 1")
                {

                    ToolTip = 'Specifies the value of the Primary Key Line 1 field';
                    ApplicationArea = NPRRetail;
                }
                field("PK Option 1"; Rec."PK Option 1")
                {

                    ToolTip = 'Specifies the value of the Primary Key Option 1 field';
                    ApplicationArea = NPRRetail;
                }
                field("Date Created"; Rec."Date Created")
                {

                    ToolTip = 'Specifies the value of the Date Created field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}


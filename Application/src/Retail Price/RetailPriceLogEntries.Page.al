page 6014475 "NPR Retail Price Log Entries"
{
    Extensible = False;
    // NPR5.40/MHA /20180316  CASE 304031 Object created

    Caption = 'Retail Price Log Entries';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Retail Price Log Entry";
    SourceTableView = SORTING("Date and Time");
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Date and Time"; Rec."Date and Time")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Date and Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Date"; Rec.Date)
                {

                    ToolTip = 'Specifies the value of the Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Time"; Rec.Time)
                {

                    ToolTip = 'Specifies the value of the Time field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Change Log Entry No."; Rec."Change Log Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Change Log Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Caption"; Rec."Table Caption")
                {

                    ToolTip = 'Specifies the value of the Table Caption field';
                    ApplicationArea = NPRRetail;
                }
                field("Field No."; Rec."Field No.")
                {

                    ToolTip = 'Specifies the value of the Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Caption"; Rec."Field Caption")
                {

                    ToolTip = 'Specifies the value of the Field Caption field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Old Value"; Rec."Old Value")
                {

                    ToolTip = 'Specifies the value of the Old Value field';
                    ApplicationArea = NPRRetail;
                }
                field("New Value"; Rec."New Value")
                {

                    ToolTip = 'Specifies the value of the New Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Update Price Log")
            {
                AccessByPermission = TableData "Change Log Entry" = R;
                Caption = 'Update Price Log';
                Image = RefreshLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Update Price Log action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RetailPriceLogMgt: Codeunit "NPR Retail Price Log Mgt.";
                begin
                    RetailPriceLogMgt.UpdatePriceLog();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}


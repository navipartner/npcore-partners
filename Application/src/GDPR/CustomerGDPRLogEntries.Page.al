page 6151151 "NPR Customer GDPR Log Entries"
{
    Extensible = False;
    // NPR5.52/JAKUBV/20191022  CASE 358656 Transport NPR5.52 - 22 October 2019
    // NPR5.55/ZESO/20200427 CASE Added field Open Journal Entries/Statement

    Caption = 'Customer GDPR Log Entries';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Customer GDPR Log Entries";
    UsageCategory = History;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No"; Rec."Entry No")
                {

                    ToolTip = 'Specifies the value of the Entry No field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No"; Rec."Customer No")
                {

                    ToolTip = 'Specifies the value of the Customer No field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Open Sales Documents"; Rec."Open Sales Documents")
                {

                    ToolTip = 'Specifies the value of the Open Sales Documents field';
                    ApplicationArea = NPRRetail;
                }
                field("Open Cust. Ledger Entry"; Rec."Open Cust. Ledger Entry")
                {

                    ToolTip = 'Specifies the value of the Open Cust. Ledger Entry field';
                    ApplicationArea = NPRRetail;
                }
                field("Has transactions"; Rec."Has transactions")
                {

                    ToolTip = 'Specifies the value of the Has transactions field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer is a Member"; Rec."Customer is a Member")
                {

                    ToolTip = 'Specifies the value of the Customer is a Member field';
                    ApplicationArea = NPRRetail;
                }
                field("Open Journal Entries/Statement"; Rec."Open Journal Entries/Statement")
                {

                    ToolTip = 'Specifies the value of the Open Journal Entries/Statement field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Entry Date Time"; Rec."Log Entry Date Time")
                {

                    ToolTip = 'Specifies the value of the Log Entry Date Time field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}


page 6151294 "NPR TM Ticket Card"
{
    PageType = Card;
    Caption = 'Ticket Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR TM Ticket";
    UsageCategory = None;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Editable = false;
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("External Ticket No."; Rec."External Ticket No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Ticket No. field';
                }
                field(AmountInclVat; Rec.AmountInclVat)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Amount Incl. VAT field';
                }
                field(AmountExclVat; Rec.AmountExclVat)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Amount Excl. VAT field';
                }
            }
            group(Dates)
            {
                Editable = true;
                Caption = 'Ticket Dates';

                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Document Date field';
                }
                field("Printed Date"; Rec."Printed Date")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Printed Date field';
                }
                field("Printed DateTime"; Rec."PrintedDateTime")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Printed DateTime field';
                }
                group(ValidFrom)
                {
                    Editable = true;
                    Caption = 'Valid From';
                    field("Valid From Date"; Rec."Valid From Date")
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Valid From Date field';
                    }
                    field("Valid From Time"; Rec."Valid From Time")
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Valid From Time field';
                    }
                }
                group(ValidTo)
                {
                    Editable = true;
                    Caption = 'Valid Until';
                    field("Valid To Date"; Rec."Valid To Date")
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Valid To Date field';
                    }
                    field("Valid To Time"; Rec."Valid To Time")
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Valid To Time field';
                    }
                }
            }

            group(References)
            {
                Caption = 'Ticket References';
                Editable = true;
                field("Sales Header No."; Rec."Sales Header No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Header No. field';
                }
                field("Sales Header Type"; Rec."Sales Header Type")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Header Type field';
                }
                field("Sales Receipt No."; Rec."Sales Receipt No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the POS Receipt No. field';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Ticket Type Code"; Rec."Ticket Type Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Type Code field';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Variant Code field';
                    Visible = false;
                }
                field("External Member Card No."; Rec."External Member Card No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Member Card No. field';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
            }
        }
    }
}
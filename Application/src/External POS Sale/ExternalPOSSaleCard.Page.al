page 6059801 "NPR External POS Sale Card"
{
    Extensible = False;
    ApplicationArea = NPRRetail;
    Caption = 'External POS Sale';
    PageType = Document;
    SourceTable = "NPR External POS Sale";
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = Not Rec."Converted To POS Entry";
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }

                field(registerNo; Rec."Register No.")
                {
                    Caption = 'POS Unit No.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Register No. field';
                }
                field(salesTicketNo; Rec."Sales Ticket No.")
                {
                    Caption = 'Sales Ticket No.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }

                field(startTime; Rec."Start Time")
                {
                    Caption = 'Start Time';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Start Time field';
                }
                field("date"; Rec."Date")
                {
                    Caption = 'Date';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sales Person Code field';
                }
                field(posStoreCode; Rec."POS Store Code")
                {
                    Caption = 'POS Store Code';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'External Document No.';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the External Document No field';
                }
                field(reference; Rec.Reference)
                {
                    Caption = 'Reference';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Reference field';
                }

                field("User ID"; Rec."User ID")
                {
                    Caption = 'User ID';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field(convertedToPOSEntry; Rec."Converted To POS Entry")
                {
                    Caption = 'Converted To POS Entry';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Converted to POS Entry field';
                }
                field(posEntrySystemId; Rec."POS Entry System Id")
                {
                    Caption = 'POS Entry System Id';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Entry System ID field';
                    trigger OnDrillDown()
                    begin
                        OpenPOSEntry();
                    end;
                }

            }

            group(ProcessingError)
            {
                Caption = 'Processing Error';
                Visible = Rec."Has Conversion Error";
                field("Has Conversion Error"; Rec."Has Conversion Error")
                {
                    Caption = 'Has Conversion Error';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Has Conversion Error field';
                }
                field("Last Conversion Error Message"; Rec."Last Conversion Error Message")
                {
                    Caption = 'Last Conversion Error Message';
                    ApplicationArea = NPRRetail;
                    MultiLine = true;
                    ToolTip = 'Specifies the value of the Last Conversion Error Message field';
                }
            }

            part(Lines; "NPR External POS Sale Subform")
            {
                Caption = 'Sales';
                Editable = NOT Rec."Converted To POS Entry";
                SubPageLink = "External POS Sale Entry No." = FIELD("Entry No.");
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ConvertToPOSEntry)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Convert To POS Entry';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = PostDocument;
                ToolTip = 'Converts an External POS Sale into a POS Entry.';
                trigger OnAction()
                var
                    ExtPOSSaleConverter: Codeunit "NPR Ext. POS Sale Converter";
                    ExtPOSSaleProcessor: Codeunit "NPR Ext. POS Sale Processor";
                    RecordAlreadyConvertedErr: Label 'This record was already converted into a POS Entry.';
                    CreatePOSEntryConfirm: Label 'Are you sure you want to convert this External POS Sale into POS Entry?';
                begin
                    IF Rec."Converted To POS Entry" then
                        Error(RecordAlreadyConvertedErr);

                    IF Not Confirm(CreatePOSEntryConfirm) then
                        exit;

                    IF NOT ExtPOSSaleConverter.Run(Rec) then begin
                        ExtPOSSaleProcessor.AddConversionError(Rec, GetLastErrorText());
                        Message(GetLastErrorText());
                    end;

                    CurrPage.Update(true);
                end;
            }
        }

        area(Navigation)
        {
            action(POSEntry)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Open POS Entry';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = ViewDetails;
                ToolTip = 'Shows created POS Entry';
                trigger OnAction()
                begin
                    OpenPOSEntry();
                end;
            }
        }
    }

    local procedure OpenPOSEntry()
    var
        POSEntryRec: Record "NPR POS Entry";
    begin
        Rec.TestField("Converted To POS Entry", true);
        Rec.TestField("POS Entry System Id");

        POSEntryRec.GetBySystemId(Rec."POS Entry System Id");
        PAGE.RunModal(Page::"NPR POS Entry Card", POSEntryRec);
    end;
}

page 6014419 "NPR Exchange Label Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'Exchange Label Setup';
    ContextSensitiveHelpPage = 'docs/retail/printing/how-to/exchange_label/';
    DeleteAllowed = false;
    Extensible = true;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR Exchange Label Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("EAN Prefix Exhange Label"; Rec."EAN Prefix Exhange Label")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the prefix used in the EAN code for exchange labels.';
                }
                field("Exchange Label  No. Series"; Rec."Exchange Label  No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies which number series is used for exchange label entries.';
                }
                field("Purchace Price Code"; Rec."Purchace Price Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the alphabetical code used to substitute numbers when displaying prices on the exchange label. A unique letter is chosen for each number from 0-9.';
                }
                field("Insert Cross Ref. Finish Sale"; Rec."Insert Cross Ref. Finish Sale")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if Cross Reference is inserted after finishing the sale';
                }
            }
            group(Validity)
            {
                Caption = 'Validity Period';

                field("Enforce Exch. Validity Period"; Rec."Enforce Exch. Validity Period")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the exchange label validity period should be respected. If enabled, the system won’t accept exchange labels outside their validity period.';
                }
                field("Exchange Label Default Date"; Rec."Exchange Label Default Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a date to use as the default "valid from"-date. Leave blank to use the date of creation (ie. "today''s date").';
                }
                field("Exchange Label Exchange Period"; Rec."Exchange Label Exchange Period")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the period length that the exchange labels should be valid for.';
                }
                field("Exchange Grace Period"; Rec."Exchange Grace Period")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the grace period during which the exchange label is still considered valid after the validity period has expired.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
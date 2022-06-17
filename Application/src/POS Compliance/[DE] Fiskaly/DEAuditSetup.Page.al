page 6014421 "NPR DE Audit Setup"
{
    Extensible = False;
    Caption = 'DE Audit Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR DE Audit Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Api URL"; Rec."Api URL")
                {
                    ToolTip = 'Specifies URL of the API';
                    ApplicationArea = NPRRetail;
                }
                field("DSFINVK Api URL"; Rec."DSFINVK Api URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies URL of the DSFINVK API';
                }
                field(ApiKeyField; ApiKeyField)
                {
                    Caption = 'Api Key';
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Api Key field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if ApiKeyField = '' then
                            DESecretMgt.RemoveSecretKey(Rec.ApiKeyLbl())
                        else
                            DESecretMgt.SetSecretKey(Rec.ApiKeyLbl(), ApiKeyField);
                    end;
                }
                field(ApiSecretField; ApiSecretField)
                {
                    Caption = 'Api Secret';
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Api Secret field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if ApiSecretField = '' then
                            DESecretMgt.RemoveSecretKey(Rec.ApiSecretLbl())
                        else
                            DESecretMgt.SetSecretKey(Rec.ApiSecretLbl(), ApiSecretField);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(PosUnitAuditInfo)
            {
                Caption = 'POS Unit Audit Info';
                Image = SetupLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "NPR DE POS Unit Aux. Info List";
                ToolTip = 'Sets additional information for POS Unit based od DE Fiskaly.';
                ApplicationArea = NPRRetail;
            }
            action(PaymentMappings)
            {
                Caption = 'Payment Method Mapping';
                ToolTip = 'Assign Fiskaly API payment types to payment methods.';
                Image = CoupledCurrency;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = page "NPR Payment Method Mapper";
                ApplicationArea = NPRRetail;
            }
            action(VATMappings)
            {
                Caption = 'VAT Posting Group Mapping';
                ToolTip = 'Assign Fiskaly API VAT types to VAT product posting groups.';
                Image = VATPostingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = page "NPR VAT Prod Post Group Mapper";
                ApplicationArea = NPRRetail;
            }
            action(DEAuditLog)
            {
                Caption = 'DE POS Audit Log';
                ToolTip = 'Shows transactions recorded in DE POS audit log with their sync. statuses.';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = page "NPR DE POS Audit Log Aux. Info";
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        if Rec."Api URL" = '' then begin
            Rec."Api URL" := 'https://kassensichv-middleware.fiskaly.com/api/v2';
            Rec.Modify();
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ApiKeyField := '';
        ApiSecretField := '';

        if DESecretMgt.HasSecretKey(Rec.ApiKeyLbl()) then
            ApiKeyField := '***';
        if DESecretMgt.HasSecretKey(Rec.ApiSecretLbl()) then
            ApiSecretField := '***';
    end;

    var
        DESecretMgt: Codeunit "NPR DE Secret Mgt.";
        ApiKeyField: Text[200];
        ApiSecretField: Text[200];
}
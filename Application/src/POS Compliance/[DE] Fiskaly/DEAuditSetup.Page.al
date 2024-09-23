page 6014421 "NPR DE Audit Setup"
{
    Extensible = False;
    Caption = 'DE Connection Parameter Set';
    ContextSensitiveHelpPage = 'docs/fiscalization/germany/how-to/setup/';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR DE Audit Setup";
    ApplicationArea = NPRDEFiscal;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Primary Key"; Rec."Primary Key")
                {
                    ToolTip = 'Specifies a code to identify this set of DE Fiskaly connection parameters.';
                    ApplicationArea = NPRDEFiscal;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the set of DE Fiskaly connection parameters.';
                    ApplicationArea = NPRDEFiscal;
                }
            }
            group(Connection)
            {
                Caption = 'Connection Parameters';
                group(URLs)
                {
                    ShowCaption = false;
                    field("Api URL"; Rec."Api URL")
                    {
                        ToolTip = 'Specifies the URL for the Fiskaly API';
                        ApplicationArea = NPRDEFiscal;
                    }
                    field("DSFINVK Api URL"; Rec."DSFINVK Api URL")
                    {
                        ApplicationArea = NPRDEFiscal;
                        ToolTip = 'Specifies URL of the DSFINVK API';
                        Importance = Additional;
                        Visible = false;
                    }
                }
                group(Keys)
                {
                    ShowCaption = false;
                    field(ApiKeyField; ApiKeyField)
                    {
                        Caption = 'Api Key';
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Api Key field';
                        ApplicationArea = NPRDEFiscal;

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
                        ApplicationArea = NPRDEFiscal;

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
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec."Api URL" = '' then
            Rec."Api URL" := 'https://kassensichv-middleware.fiskaly.com/api/v2';
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
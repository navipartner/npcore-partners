page 6151279 "NPR POS DS Exten. Field Setup"
{
    Extensible = false;
    Caption = 'POS Data Source Exten. Field Setup';
    PageType = List;
    SourceTable = "NPR POS DS Exten. Field Setup";
    UsageCategory = None;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Extension Module"; Rec."Extension Module")
                {
                    ToolTip = 'Specifies the module this POS data source extension field is introduced by.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Data Source Name"; Rec."Data Source Name")
                {
                    ToolTip = 'Specifies the POS data source this extension field is part of.';
                    ApplicationArea = NPRRetail;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DataSourceExtFieldMgt: Codeunit "NPR POS DS Exten. Field Mgt.";
                    begin
                        exit(DataSourceExtFieldMgt.LookupDataSource(Rec."Extension Module", Text));
                    end;
                }
                field("Extension Name"; Rec."Extension Name")
                {
                    ToolTip = 'Specifies the extension name this POS data source extension field is introduced by. The name is used to reference the extension field instance defined on this line.';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DataSourceExtFieldMgt: Codeunit "NPR POS DS Exten. Field Mgt.";
                    begin
                        exit(DataSourceExtFieldMgt.LookupExtensionName(Rec."Extension Module", Rec."Data Source Name", Text));
                    end;
                }
                field("Extension Field"; Rec."Extension Field")
                {
                    ToolTip = 'Specifies the extension field you want to set up in this line.';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DataSourceExtFieldMgt: Codeunit "NPR POS DS Exten. Field Mgt.";
                    begin
                        exit(DataSourceExtFieldMgt.LookupExtensionField(Rec."Extension Module", Rec."Data Source Name", Rec."Extension Name", Text));
                    end;
                }
                field("Exclude from Data Source"; Rec."Exclude from Data Source")
                {
                    ToolTip = 'Specifies whether you want to exclude this extension field instance from specified POS data source. Please note that marking all instances of an extension field as excluded from a POS data source won’t result in system adding the default instance of this field to the data source. If you want the default instance of the extension field to appear in the data souce, you will have to delete all custom instances of the extension field from this page.';
                    ApplicationArea = NPRRetail;
                }
                field("Exten.Field Instance Name"; Rec."Exten.Field Instance Name")
                {
                    ToolTip = 'Specifies the name of this POS data source extension field instance. The name is used to reference the extension field instance defined on this line.';
                    ApplicationArea = NPRRetail;
                    Enabled = not Rec."Exclude from Data Source";
                }
                field("Exten.Field Instance Descript."; Rec."Exten.Field Instance Descript.")
                {
                    ToolTip = 'Specifies a short description of this POS data source extension field instance.';
                    ApplicationArea = NPRRetail;
                    Enabled = not Rec."Exclude from Data Source";
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies a unique entry ID.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            part(DSExtFldAddParams; "NPR DS Ext.Field Setup FactBox")
            {
                ApplicationArea = NPRRetail;
                Editable = false;
                SubPageLink = "Entry No." = field("Entry No.");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(OpenAdditionalParameterSetupPage)
            {
                Caption = 'Additional Parameters';
                ToolTip = 'Opens additional parameter setup page for the POS data source extension field instance.';
                ApplicationArea = NPRRetail;
                Image = QuestionaireSetup;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    DataSourceExtFieldMgt: Codeunit "NPR POS DS Exten. Field Mgt.";
                begin
                    CurrPage.SaveRecord();
                    DataSourceExtFieldMgt.OpenAdditionalParameterPage(Rec, CurrPage.Editable());
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetExtensionModuleFromFilter();
    end;

    trigger OnOpenPage()
    begin
        UpdatePageCaption();
    end;

    local procedure UpdatePageCaption()
    var
        PageCaption: Text;
        CollectPageCaptionLbl: Label 'Collect Data Source Exten. Field Location Setup';
        DocImportPageCaptionLbl: Label 'Doc.Import Data Source Exten. Field Location Setup';
    begin
        case Rec.GetExtensionModuleFromFilter() of
            Enum::"NPR POS DS Extension Module"::DocImport:
                PageCaption := DocImportPageCaptionLbl;
            Enum::"NPR POS DS Extension Module"::ClickCollect:
                PageCaption := CollectPageCaptionLbl;
            else
                PageCaption := '';
        end;

        if PageCaption <> '' then
            CurrPage.Caption(PageCaption);
    end;
}

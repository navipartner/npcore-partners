page 6151419 "NPR Magento Brand Card"
{
    UsageCategory = None;
    Caption = 'Brand Card';
    DelayedInsert = true;
    SourceTable = "NPR Magento Brand";

    layout
    {
        area(content)
        {
            group(Control6150613)
            {
                ShowCaption = false;
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Id field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';

                    trigger OnValidate()
                    begin
                        if Rec."Seo Link" <> '' then
                            if not Confirm(Text001, false) then
                                exit;
                        Rec.Validate("Seo Link", Rec.Name);
                        CurrPage.Update(true);
                    end;
                }
                field("FORMAT(Description.HASVALUE)"; Format(Rec.Description.HasValue))
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';

                    trigger OnAssistEdit()
                    var
                        RecRef: RecordRef;
                        FieldRef: FieldRef;
                    begin
                        RecRef.GetTable(Rec);
                        FieldRef := RecRef.Field(Rec.FieldNo(Description));
                        if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                            RecRef.SetTable(Rec);
                            Rec.Modify(true);
                        end;
                    end;
                }
                field("FORMAT(""Short Description"".HASVALUE)"; Format(Rec."Short Description".HasValue))
                {
                    ApplicationArea = All;
                    Caption = 'Short Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Short Description field';

                    trigger OnAssistEdit()
                    var
                        RecRef: RecordRef;
                        FieldRef: FieldRef;
                    begin
                        RecRef.GetTable(Rec);
                        FieldRef := RecRef.Field(Rec.FieldNo("Short Description"));
                        if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                            RecRef.SetTable(Rec);
                            Rec.Modify(true);
                        end;
                    end;
                }
                field("Seo Link"; Rec."Seo Link")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seo Link field';
                }
                field("Meta Title"; Rec."Meta Title")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Meta Title field';
                }
                field("Meta Description"; Rec."Meta Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Meta Description field';
                }
                field(Picture; Rec.Picture)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture field';
                }
                field("Logo Picture"; Rec."Logo Picture")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Logo field';
                }
                field("Sorting"; Rec.Sorting)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sorting field';
                }
            }
        }
        area(factboxes)
        {
            part(PictureDragDropAddin; "NPR Magento DragDropPic. Addin")
            {
                Caption = 'Picture';
                Editable = false;
                ShowFilter = false;
                SubPageLink = Type = CONST(Brand),
                              Name = FIELD(Picture);
                ApplicationArea = All;
            }
            part(LogoPictureDragDropAddin; "NPR Magento DragDropPic. Addin")
            {
                Caption = 'Logo';
                Editable = false;
                ShowFilter = false;
                SubPageLink = Type = CONST(Brand),
                              Name = FIELD("Logo Picture");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(List)
            {
                Caption = 'List';
                Image = List;
                RunObject = Page "NPR Magento Brands";
                ShortCutKey = 'F5';
                ApplicationArea = All;
                ToolTip = 'Executes the List action';
            }
            action("Display Config")
            {
                Caption = 'Display Config';
                Image = ViewPage;
                Visible = DisplayConfigVisible;
                ApplicationArea = All;
                ToolTip = 'Executes the Display Config action';

                trigger OnAction()
                var
                    MagentoDisplayConfigPage: Page "NPR Magento Display Config";
                    MagentoDisplayConfig: Record "NPR Magento Display Config";
                begin
                    MagentoDisplayConfig.SetRange("No.", Rec.Id);
                    MagentoDisplayConfig.SetRange(Type, MagentoDisplayConfig.Type::Brand);
                    MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                    MagentoDisplayConfigPage.Run;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.PictureDragDropAddin.PAGE.SetBrandCode(Rec.Id, false);
        CurrPage.LogoPictureDragDropAddin.PAGE.SetBrandCode(Rec.Id, true);
    end;

    trigger OnOpenPage()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        HasSetupBrands := MagentoSetupMgt.HasSetupBrands();
        CurrPage.Editable(not HasSetupBrands);

        SetDisplayConfigVisible;
    end;

    var
        MagentoFunctions: Codeunit "NPR Magento Functions";
        Text001: Label 'Update Seo Link?';
        DisplayConfigVisible: Boolean;
        HasSetupBrands: Boolean;

    local procedure SetDisplayConfigVisible()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        DisplayConfigVisible := MagentoSetup.Get and MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled";
    end;
}
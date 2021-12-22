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

                    ToolTip = 'Specifies the value of the Id field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        if Rec."Seo Link" <> '' then
                            if not Confirm(Text001, false) then
                                exit;
                        Rec.Validate("Seo Link", Rec.Name);
                        CurrPage.Update(true);
                    end;
                }
                field("Description"; Format(Rec.Description.HasValue))
                {

                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    var
                        TempBlob: Codeunit "Temp Blob";
                        OutStr: OutStream;
                        InStr: InStream;
                    begin
                        TempBlob.CreateOutStream(OutStr);
                        Rec."Description".CreateInStream(InStr);
                        CopyStream(OutStr, InStr);
                        if MagentoFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                            if TempBlob.HasValue() then begin
                                TempBlob.CreateInStream(InStr);
                                Rec."Description".CreateOutStream(OutStr);
                                CopyStream(OutStr, InStr);
                            end else
                                Clear(Rec."Description");
                            Rec.Modify(true);
                        end;
                    end;
                }
                field("Short Description"; Format(Rec."Short Description".HasValue))
                {

                    Caption = 'Short Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Short Description field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    var
                        TempBlob: Codeunit "Temp Blob";
                        OutStr: OutStream;
                        InStr: InStream;
                    begin
                        TempBlob.CreateOutStream(OutStr);
                        Rec."Short Description".CreateInStream(InStr);
                        CopyStream(OutStr, InStr);
                        if MagentoFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                            if TempBlob.HasValue() then begin
                                TempBlob.CreateInStream(InStr);
                                Rec."Short Description".CreateOutStream(OutStr);
                                CopyStream(OutStr, InStr);
                            end else
                                Clear(Rec."Short Description");
                            Rec.Modify(true);
                        end;
                    end;
                }
                field("Seo Link"; Rec."Seo Link")
                {

                    ToolTip = 'Specifies the value of the Seo Link field';
                    ApplicationArea = NPRRetail;
                }
                field("Meta Title"; Rec."Meta Title")
                {

                    ToolTip = 'Specifies the value of the Meta Title field';
                    ApplicationArea = NPRRetail;
                }
                field("Meta Description"; Rec."Meta Description")
                {

                    ToolTip = 'Specifies the value of the Meta Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Picture; Rec.Picture)
                {

                    ToolTip = 'Specifies the value of the Picture field';
                    ApplicationArea = NPRRetail;
                }
                field("Logo Picture"; Rec."Logo Picture")
                {

                    ToolTip = 'Specifies the value of the Logo field';
                    ApplicationArea = NPRRetail;
                }
                field("Sorting"; Rec.Sorting)
                {

                    ToolTip = 'Specifies the value of the Sorting field';
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;

            }
            part(LogoPictureDragDropAddin; "NPR Magento DragDropPic. Addin")
            {
                Caption = 'Logo';
                Editable = false;
                ShowFilter = false;
                SubPageLink = Type = CONST(Brand),
                              Name = FIELD("Logo Picture");
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the List action';
                ApplicationArea = NPRRetail;
            }
            action("Display Config")
            {
                Caption = 'Display Config';
                Image = ViewPage;
                Visible = DisplayConfigVisible;

                ToolTip = 'Executes the Display Config action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MagentoDisplayConfig: Record "NPR Magento Display Config";
                    MagentoDisplayConfigPage: Page "NPR Magento Display Config";
                begin
                    MagentoDisplayConfig.SetRange("No.", Rec.Id);
                    MagentoDisplayConfig.SetRange(Type, MagentoDisplayConfig.Type::Brand);
                    MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                    MagentoDisplayConfigPage.Run();
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

        SetDisplayConfigVisible();
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
        DisplayConfigVisible := MagentoSetup.Get() and MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled";
    end;
}
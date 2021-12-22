page 6151414 "NPR Magento Category Card"
{
    UsageCategory = None;
    Caption = 'Magento Category Card';
    DelayedInsert = true;
    InsertAllowed = false;
    SourceTable = "NPR Magento Category";

    layout
    {
        area(content)
        {
            group("Item Group")
            {
                Caption = 'Item Group';
                group(Control6150614)
                {
                    Enabled = (NOT Rec.Root);
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
                            if not Confirm(Text001, false) then
                                exit;
                            Rec.Validate("Seo Link", Rec.Name);
                            CurrPage.Update(true);
                        end;
                    }
                    field("Description"; Format(Rec.Description.HasValue))
                    {

                        AssistEdit = true;
                        Caption = 'Description';
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
                    field(Picture; Rec.Picture)
                    {

                        ToolTip = 'Specifies the value of the Picture field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6150620)
                {
                    Editable = (NOT Rec.Root);
                    ShowCaption = false;
                    field("Is Active"; Rec."Is Active")
                    {

                        ToolTip = 'Specifies the value of the Is Active field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Is Anchor"; Rec."Is Anchor")
                    {

                        ToolTip = 'Specifies the value of the Is Anchor field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show In Navigation Menu"; Rec."Show In Navigation Menu")
                    {

                        ToolTip = 'Specifies the value of the Show In Navigation Menu field';
                        ApplicationArea = NPRRetail;
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
                    field("Meta Keywords"; Rec."Meta Keywords")
                    {

                        ToolTip = 'Specifies the value of the Meta Keywords field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Meta Description"; Rec."Meta Description")
                    {

                        ToolTip = 'Specifies the value of the Meta Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sorting"; Rec.Sorting)
                    {

                        ToolTip = 'Specifies the value of the Sorting field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Icon; Rec.Icon)
                    {

                        ToolTip = 'Specifies the value of the Icon field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            part(MagentoChildCategories; "NPR Magento Child Categories")
            {
                Caption = 'Child Categories';
                ShowFilter = false;
                SubPageLink = "Parent Category Id" = FIELD(FILTER(Id));
                Visible = MagentoItemGroupSubformVisible;
                ApplicationArea = NPRRetail;

            }
        }
        area(factboxes)
        {
            part(PictureDragDropAddin; "NPR Magento DragDropPic. Addin")
            {
                SubPageLink = Type = CONST("Item Group"),
                              Name = FIELD(Picture);
                Visible = (NOT HasSetupCategories);
                ApplicationArea = NPRRetail;

            }
            part(IconPictureDragDropAddin; "NPR Magento DragDropPic. Addin")
            {
                Caption = 'Icon';
                Editable = false;
                ShowFilter = false;
                SubPageLink = Type = CONST("Item Group"),
                              Name = FIELD(Icon);
                Visible = (NOT HasSetupCategories);
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(navigation)
        {
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
                    MagentoDisplayConfig.SetRange(Type, MagentoDisplayConfig.Type::"Item Group");
                    MagentoDisplayConfig.SetRange("No.", Rec.Id);
                    MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                    MagentoDisplayConfigPage.Run();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        MagentoItemGroupSubformVisible := Rec.Find();
        CurrPage.MagentoChildCategories.PAGE.SetParentItemGroup(Rec);
        CurrPage.PictureDragDropAddin.PAGE.SetItemGroupNo(Rec.Id, false);
        CurrPage.IconPictureDragDropAddin.PAGE.SetItemGroupNo(Rec.Id, true);
    end;

    trigger OnOpenPage()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        HasSetupCategories := MagentoSetupMgt.HasSetupCategories();
        CurrPage.Editable(not HasSetupCategories);
        SetDisplayConfigVisible();
    end;

    var
        MagentoFunctions: Codeunit "NPR Magento Functions";
        Text001: Label 'Update Seo Link?';
        DisplayConfigVisible: Boolean;
        MagentoItemGroupSubformVisible: Boolean;
        HasSetupCategories: Boolean;

    local procedure SetDisplayConfigVisible()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        DisplayConfigVisible := MagentoSetup.Get() and MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled";
    end;
}
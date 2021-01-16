page 6151419 "NPR Magento Brand Card"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MH/20150201  CASE 199932 Added new picture fields
    // MAG1.03/MH/20150205  CASE 199932 Removed Description Picture
    // MAG1.04/MH/20150209  CASE 199932 Updated PictureViewer Addin
    // MAG1.14/MH/20150508  CASE 211881 Updated PictureViewer Addin to JavaScript version
    // MAG1.20/TS/20151005 CASE 224193  Added field Sorting
    // MAG1.21/TR/20151028  CASE 225601 Shortcut to Display Config added
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.09/TS  /20180108  CASE 300893 Removed Caption on Action Container
    // MAG2.23/BHR /20190730  CASE 362728 Add Short Description
    // MAG2.26/MHA /20200601  CASE 404580 Magento Brands can now be managed externally

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
                field(Id; Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Id field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';

                    trigger OnValidate()
                    begin
                        if "Seo Link" <> '' then
                            if not Confirm(Text001, false) then
                                exit;
                        Validate("Seo Link", Name);
                        CurrPage.Update(true);
                    end;
                }
                field("FORMAT(Description.HASVALUE)"; Format(Description.HasValue))
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
                        FieldRef := RecRef.Field(FieldNo(Description));
                        if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                            RecRef.SetTable(Rec);
                            Modify(true);
                        end;
                    end;
                }
                field("FORMAT(""Short Description"".HASVALUE)"; Format("Short Description".HasValue))
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
                        FieldRef := RecRef.Field(FieldNo("Short Description"));
                        if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                            RecRef.SetTable(Rec);
                            Modify(true);
                        end;
                    end;
                }
                field("Seo Link"; "Seo Link")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seo Link field';
                }
                field("Meta Title"; "Meta Title")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Meta Title field';
                }
                field("Meta Description"; "Meta Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Meta Description field';
                }
                field(Picture; Picture)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture field';
                }
                field("Logo Picture"; "Logo Picture")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Logo field';
                }
                field("Sorting"; Sorting)
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
                    //-MAG1.21
                    MagentoDisplayConfig.SetRange("No.", Id);
                    MagentoDisplayConfig.SetRange(Type, MagentoDisplayConfig.Type::Brand);
                    MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                    MagentoDisplayConfigPage.Run;
                    //+MAG1.21
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.PictureDragDropAddin.PAGE.SetBrandCode(Id, false);
        CurrPage.LogoPictureDragDropAddin.PAGE.SetBrandCode(Id, true);
    end;

    trigger OnOpenPage()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        //-MAG2.26 [404580]
        HasSetupBrands := MagentoSetupMgt.HasSetupBrands();
        CurrPage.Editable(not HasSetupBrands);
        //+MAG2.26 [404580]

        //-MAG1.21
        SetDisplayConfigVisible;
        //+MAG1.21
    end;

    var
        MagentoFunctions: Codeunit "NPR Magento Functions";
        Text001: Label 'Update Seo Link?';
        PictureViewerReady: Boolean;
        DisplayConfigVisible: Boolean;
        HasSetupBrands: Boolean;

    local procedure SetDisplayConfigVisible()
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoWebsite: Record "NPR Magento Website";
    begin
        //-MAG1.21
        DisplayConfigVisible := MagentoSetup.Get and MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled";
        //+MAG1.21
    end;
}


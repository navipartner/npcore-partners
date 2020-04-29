page 6151414 "Magento Item Group"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MH/20150115  CASE 199932 Updated Layout
    // MAG1.04/MH/20150209  CASE 199932 Updated PictureViewer Addin
    // MAG1.14/MH/20150508  CASE 211881 Updated PictureViewer Addin to JavaScript version
    // MAG1.17/TR/20150618  CASE 210548 Magento Multistore Page added.
    // MAG1.21/TR/20151028  CASE 225601 Shortcut to Display Config added
    // MAG1.22/MHA/20151120 CASE 227359 Removed InsertAllowed and PagePart Store Values
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/TS  /20181017  CASE 324862 Added Icon Picture
    // MAG2.17/TS  /20181112  CASE 333862 Seo Link Should not be updated if No is selected.
    // MAG2.20/BHR /20190409  CASE 346352 Field 130 "Short Description"

    Caption = 'Item Group';
    DelayedInsert = true;
    InsertAllowed = false;
    SourceTable = "Magento Item Group";

    layout
    {
        area(content)
        {
            group("Item Group")
            {
                Caption = 'Item Group';
                group(Control6150614)
                {
                    Enabled = (NOT Root);
                    ShowCaption = false;
                    field("No.";"No.")
                    {
                    }
                    field(Name;Name)
                    {

                        trigger OnValidate()
                        begin
                            //-MAG2.17 [333862]
                            //IF "Seo Link" <> '' THEN
                            //  IF NOT CONFIRM(Text001,FALSE) THEN
                            //    EXIT
                            if not Confirm(Text001,false) then
                              exit;
                            Validate("Seo Link",Name);
                            //-MAG2.17 [333862]
                            CurrPage.Update(true);
                        end;
                    }
                    field("FORMAT(Description.HASVALUE)";Format(Description.HasValue))
                    {
                        AssistEdit = true;
                        Caption = 'Description';

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
                    field("FORMAT(""Short Description"".HASVALUE)";Format("Short Description".HasValue))
                    {
                        Caption = 'Short Description';

                        trigger OnAssistEdit()
                        var
                            RecRef: RecordRef;
                            FieldRef: FieldRef;
                        begin
                            //-MAG2.20 [346352]
                            RecRef.GetTable(Rec);
                            FieldRef := RecRef.Field(FieldNo("Short Description"));
                            if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                              RecRef.SetTable(Rec);
                              Modify(true);
                            end;
                            //+MAG2.20 [346352]
                        end;
                    }
                    field(Picture;Picture)
                    {
                    }
                }
                group(Control6150620)
                {
                    Editable = (NOT Root);
                    ShowCaption = false;
                    field("Is Active";"Is Active")
                    {
                    }
                    field("Is Anchor";"Is Anchor")
                    {
                    }
                    field("Show In Navigation Menu";"Show In Navigation Menu")
                    {
                    }
                    field("Seo Link";"Seo Link")
                    {
                    }
                    field("Meta Title";"Meta Title")
                    {
                    }
                    field("Meta Keywords";"Meta Keywords")
                    {
                    }
                    field("Meta Description";"Meta Description")
                    {
                    }
                    field(Sorting;Sorting)
                    {
                    }
                    field(Icon;Icon)
                    {
                    }
                }
            }
            part(MagentoItemGroupSubform;"Magento Item Group Subform")
            {
                Caption = 'Child Item Groups';
                ShowFilter = false;
                SubPageLink = "Parent Item Group No."=FIELD(FILTER("No."));
                Visible = MagentoItemGroupSubformVisible;
            }
        }
        area(factboxes)
        {
            part(PictureDragDropAddin;"Magento DragDropPic. Addin")
            {
                SubPageLink = Type=CONST("Item Group"),
                              Name=FIELD(Picture);
            }
            part(IconPictureDragDropAddin;"Magento DragDropPic. Addin")
            {
                Caption = 'Icon';
                Editable = false;
                ShowFilter = false;
                SubPageLink = Type=CONST("Item Group"),
                              Name=FIELD(Icon);
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

                trigger OnAction()
                var
                    MagentoDisplayConfigPage: Page "Magento Display Config";
                    MagentoDisplayConfig: Record "Magento Display Config";
                begin
                    //-MAG1.21
                    MagentoDisplayConfig.SetRange(Type,MagentoDisplayConfig.Type::"Item Group");
                    MagentoDisplayConfig.SetRange("No.","No.");
                    MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                    MagentoDisplayConfigPage.Run;
                    //+MAG1.21
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        MagentoItemGroupSubformVisible := Find;
        CurrPage.MagentoItemGroupSubform.PAGE.SetParentItemGroup(Rec);
        //-MAG2.17 [324862]
        //CurrPage.PictureDragDropAddin.PAGE.SetItemGroupNo("No.");
        CurrPage.PictureDragDropAddin.PAGE.SetItemGroupNo("No.",false);
        CurrPage.IconPictureDragDropAddin.PAGE.SetItemGroupNo("No.",true);
        //+MAG2.17 [324862]
    end;

    trigger OnOpenPage()
    begin
        //-MAG1.21
        ////-MAG1.17
        //SetStoreVisible;
        ////+MAG1.17
        //+MAG1.21

        //-MAG1.21
        SetDisplayConfigVisible;
        //+MAG1.21
    end;

    var
        MagentoFunctions: Codeunit "Magento Functions";
        Text001: Label 'Update Seo Link?';
        DisplayConfigVisible: Boolean;
        MagentoItemGroupSubformVisible: Boolean;

    local procedure SetDisplayConfigVisible()
    var
        MagentoSetup: Record "Magento Setup";
        MagentoWebsite: Record "Magento Website";
    begin
        //-MAG1.21
        DisplayConfigVisible := MagentoSetup.Get and MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled";
        //+MAG1.21
    end;
}


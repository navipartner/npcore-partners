page 6151445 "Magento Store Items"
{
    // MAG1.16/TR  /20150402  CASE 210548 Object created and modified for use.
    // MAG1.17/TR  /20150522  CASE 210548 Object modified for use.
    // MAG1.21/MHA /20151120  CASE 227354 Changed usage of page from PagePart to ListPlus in order to Show Stores per Item
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG9.00.2.11/TS  /20180301  CASE 305585 Added field Visibility.

    Caption = 'Magento Webshop Items';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPlus;
    ShowFilter = false;
    SourceTable = "Magento Store Item";
    SourceTableView = SORTING("Item No.","Store Code");

    layout
    {
        area(content)
        {
            group(Control6150694)
            {
                ShowCaption = false;
                grid(Control6150693)
                {
                    GridLayout = Columns;
                    ShowCaption = false;
                    group(Control6150692)
                    {
                        ShowCaption = false;
                        repeater(Group)
                        {
                            field(Webshop;Webshop)
                            {
                            }
                            field("Store Code";"Store Code")
                            {
                                Editable = false;
                            }
                            field("Website Code";"Website Code")
                            {
                                Editable = false;
                            }
                            field(Enabled;Enabled)
                            {

                                trigger OnValidate()
                                begin
                                    CurrPage.Update(true);
                                end;
                            }
                            field(GetEnabledFieldsCaption;GetEnabledFieldsCaption)
                            {
                                Caption = 'Fields Enabled';
                                Editable = false;
                            }
                        }
                        group(Control6150685)
                        {
                            ShowCaption = false;
                        }
                    }
                    group(Control6150684)
                    {
                        ShowCaption = false;
                        part(MagentoItemGroupLinks;"Magento Item Group Link")
                        {
                            SubPageLink = "Item No."=FIELD("Item No.");
                        }
                    }
                    group(Control6150682)
                    {
                        ShowCaption = false;
                        group(Control6150681)
                        {
                            ShowCaption = false;
                            group(Website)
                            {
                                Caption = 'Website';
                                grid(Control6150679)
                                {
                                    ShowCaption = false;
                                    group(Control6150678)
                                    {
                                        ShowCaption = false;
                                        field("Unit Price";"Unit Price")
                                        {
                                        }
                                    }
                                    group(Control6150676)
                                    {
                                        ShowCaption = false;
                                        field("Unit Price Enabled";"Unit Price Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150674)
                                {
                                    ShowCaption = false;
                                    group(Control6150673)
                                    {
                                        ShowCaption = false;
                                        field("Product New From";"Product New From")
                                        {
                                        }
                                    }
                                    group(Control6150671)
                                    {
                                        ShowCaption = false;
                                        field("Product New From Enabled";"Product New From Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150669)
                                {
                                    ShowCaption = false;
                                    group(Control6150668)
                                    {
                                        ShowCaption = false;
                                        field("Product New To";"Product New To")
                                        {
                                        }
                                    }
                                    group(Control6150666)
                                    {
                                        ShowCaption = false;
                                        field("Product New To Enabled";"Product New To Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150664)
                                {
                                    ShowCaption = false;
                                    group(Control6150663)
                                    {
                                        ShowCaption = false;
                                        field("Special Price";"Special Price")
                                        {
                                        }
                                    }
                                    group(Control6150661)
                                    {
                                        ShowCaption = false;
                                        field("Special Price Enabled";"Special Price Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150659)
                                {
                                    ShowCaption = false;
                                    group(Control6150658)
                                    {
                                        ShowCaption = false;
                                        field("Special Price From";"Special Price From")
                                        {
                                        }
                                    }
                                    group(Control6150656)
                                    {
                                        ShowCaption = false;
                                        field("Special Price From Enabled";"Special Price From Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150654)
                                {
                                    ShowCaption = false;
                                    group(Control6150653)
                                    {
                                        ShowCaption = false;
                                        field("Special Price To";"Special Price To")
                                        {
                                        }
                                    }
                                    group(Control6150651)
                                    {
                                        ShowCaption = false;
                                        field("Special Price To Enabled";"Special Price To Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                            }
                        }
                        group(Store)
                        {
                            Caption = 'Store';
                            group(Control6150648)
                            {
                                ShowCaption = false;
                                grid(Control6150647)
                                {
                                    ShowCaption = false;
                                    group(Control6150646)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Name";"Webshop Name")
                                        {
                                            Caption = 'Name';
                                        }
                                    }
                                    group(Control6150644)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Name Enabled";"Webshop Name Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150642)
                                {
                                    ShowCaption = false;
                                    group(Control6150641)
                                    {
                                        ShowCaption = false;
                                        field("FORMAT(""Webshop Description"".HASVALUE)";Format("Webshop Description".HasValue))
                                        {
                                            Caption = 'Description';

                                            trigger OnAssistEdit()
                                            var
                                                RecRef: RecordRef;
                                                FieldRef: FieldRef;
                                                MagentoFunctions: Codeunit "Magento Functions";
                                            begin
                                                RecRef.GetTable(Rec);
                                                FieldRef := RecRef.Field(FieldNo("Webshop Description"));
                                                if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                                                  RecRef.SetTable(Rec);
                                                  Modify(true);
                                                end;
                                            end;
                                        }
                                    }
                                    group(Control6150639)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Description Enabled";"Webshop Description Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150637)
                                {
                                    ShowCaption = false;
                                    group(Control6150636)
                                    {
                                        ShowCaption = false;
                                        field("FORMAT(""Webshop Short Desc."".HASVALUE)";Format("Webshop Short Desc.".HasValue))
                                        {
                                            Caption = 'Short Description';

                                            trigger OnAssistEdit()
                                            var
                                                RecRef: RecordRef;
                                                FieldRef: FieldRef;
                                                MagentoFunctions: Codeunit "Magento Functions";
                                            begin
                                                RecRef.GetTable(Rec);
                                                FieldRef := RecRef.Field(FieldNo("Webshop Short Desc."));
                                                if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                                                  RecRef.SetTable(Rec);
                                                  Modify(true);
                                                end;
                                            end;
                                        }
                                    }
                                    group(Control6150634)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Short Desc. Enabled";"Webshop Short Desc. Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6151401)
                                {
                                    ShowCaption = false;
                                    group(Control6151400)
                                    {
                                        ShowCaption = false;
                                        field(Visibility;Visibility)
                                        {
                                        }
                                    }
                                }
                                grid(Control6150632)
                                {
                                    ShowCaption = false;
                                    group(Control6150631)
                                    {
                                        ShowCaption = false;
                                        field("Display Only";"Display Only")
                                        {
                                        }
                                    }
                                    group(Control6150629)
                                    {
                                        ShowCaption = false;
                                        field("Display Only Enabled";"Display Only Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150627)
                                {
                                    ShowCaption = false;
                                    group(Control6150626)
                                    {
                                        ShowCaption = false;
                                        field("Seo Link";"Seo Link")
                                        {
                                        }
                                    }
                                    group(Control6150624)
                                    {
                                        ShowCaption = false;
                                        field("Seo Link Enabled";"Seo Link Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150622)
                                {
                                    ShowCaption = false;
                                    group(Control6150621)
                                    {
                                        ShowCaption = false;
                                        field("Meta Title";"Meta Title")
                                        {
                                        }
                                    }
                                    group(Control6150619)
                                    {
                                        ShowCaption = false;
                                        field("Meta Title Enabled";"Meta Title Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150617)
                                {
                                    ShowCaption = false;
                                    group(Control6150616)
                                    {
                                        ShowCaption = false;
                                        field("Meta Description";"Meta Description")
                                        {
                                        }
                                    }
                                    group(Control6150614)
                                    {
                                        ShowCaption = false;
                                        field("Meta Description Enabled";"Meta Description Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-MAG1.21
        CurrPage.MagentoItemGroupLinks.PAGE.SetRootNo("Root Item Group No.");
        //+MAG1.21
    end;

    trigger OnAfterGetRecord()
    begin
        Storecode := "Store Code";
    end;

    var
        Storecode: Code[32];
}


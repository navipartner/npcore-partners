page 6151439 "Magento Store Item List"
{
    // MAG1.21/MHA /20151118  CASE 227354 Object created
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG9.00.2.11/TS  /20180301  CASE 305585 Added field Visibility.
    // MAG2.26/MHA /20200601  CASE 404580 Magento "Item Group" renamed to "Category"

    Caption = 'Webshops';
    PageType = ListPlus;
    SourceTable = "Magento Store Item";

    layout
    {
        area(content)
        {
            group(Control6150620)
            {
                ShowCaption = false;
                grid(Control6150652)
                {
                    GridLayout = Columns;
                    ShowCaption = false;
                    group(Control6150626)
                    {
                        ShowCaption = false;
                        repeater(Group)
                        {
                            field("Item No.";"Item No.")
                            {
                            }
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
                        group(Control6150653)
                        {
                            ShowCaption = false;
                        }
                    }
                    group(Control6150623)
                    {
                        ShowCaption = false;
                        part(MagentoCategoryLinks;"Magento Category Links")
                        {
                            Caption = 'Magento Category Links';
                            SubPageLink = "Item No."=FIELD("Item No.");
                        }
                    }
                    group(Control6150693)
                    {
                        ShowCaption = false;
                        group(Control6150694)
                        {
                            ShowCaption = false;
                            group(Website)
                            {
                                Caption = 'Website';
                                grid(Control6150692)
                                {
                                    ShowCaption = false;
                                    group(Control6150689)
                                    {
                                        ShowCaption = false;
                                        field("Unit Price";"Unit Price")
                                        {
                                        }
                                    }
                                    group(Control6150687)
                                    {
                                        ShowCaption = false;
                                        field("Unit Price Enabled";"Unit Price Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150685)
                                {
                                    ShowCaption = false;
                                    group(Control6150686)
                                    {
                                        ShowCaption = false;
                                        field("Product New From";"Product New From")
                                        {
                                        }
                                    }
                                    group(Control6150684)
                                    {
                                        ShowCaption = false;
                                        field("Product New From Enabled";"Product New From Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150682)
                                {
                                    ShowCaption = false;
                                    group(Control6150679)
                                    {
                                        ShowCaption = false;
                                        field("Product New To";"Product New To")
                                        {
                                        }
                                    }
                                    group(Control6150677)
                                    {
                                        ShowCaption = false;
                                        field("Product New To Enabled";"Product New To Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150675)
                                {
                                    ShowCaption = false;
                                    group(Control6150676)
                                    {
                                        ShowCaption = false;
                                        field("Special Price";"Special Price")
                                        {
                                        }
                                    }
                                    group(Control6150674)
                                    {
                                        ShowCaption = false;
                                        field("Special Price Enabled";"Special Price Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150672)
                                {
                                    ShowCaption = false;
                                    group(Control6150669)
                                    {
                                        ShowCaption = false;
                                        field("Special Price From";"Special Price From")
                                        {
                                        }
                                    }
                                    group(Control6150667)
                                    {
                                        ShowCaption = false;
                                        field("Special Price From Enabled";"Special Price From Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150665)
                                {
                                    ShowCaption = false;
                                    group(Control6150666)
                                    {
                                        ShowCaption = false;
                                        field("Special Price To";"Special Price To")
                                        {
                                        }
                                    }
                                    group(Control6150664)
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
                            group(Control6150659)
                            {
                                ShowCaption = false;
                                grid(Control6150660)
                                {
                                    ShowCaption = false;
                                    group(Control6150657)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Name";"Webshop Name")
                                        {
                                            Caption = 'Name';
                                        }
                                    }
                                    group(Control6150655)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Name Enabled";"Webshop Name Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150651)
                                {
                                    ShowCaption = false;
                                    group(Control6150654)
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
                                    group(Control6150650)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Description Enabled";"Webshop Description Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150648)
                                {
                                    ShowCaption = false;
                                    group(Control6150645)
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
                                    group(Control6150643)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Short Desc. Enabled";"Webshop Short Desc. Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6151402)
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
                                grid(Control6150641)
                                {
                                    ShowCaption = false;
                                    group(Control6150642)
                                    {
                                        ShowCaption = false;
                                        field("Display Only";"Display Only")
                                        {
                                        }
                                    }
                                    group(Control6150640)
                                    {
                                        ShowCaption = false;
                                        field("Display Only Enabled";"Display Only Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150638)
                                {
                                    ShowCaption = false;
                                    group(Control6150635)
                                    {
                                        ShowCaption = false;
                                        field("Seo Link";"Seo Link")
                                        {
                                        }
                                    }
                                    group(Control6150633)
                                    {
                                        ShowCaption = false;
                                        field("Seo Link Enabled";"Seo Link Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150631)
                                {
                                    ShowCaption = false;
                                    group(Control6150632)
                                    {
                                        ShowCaption = false;
                                        field("Meta Title";"Meta Title")
                                        {
                                        }
                                    }
                                    group(Control6150630)
                                    {
                                        ShowCaption = false;
                                        field("Meta Title Enabled";"Meta Title Enabled")
                                        {
                                            ShowCaption = false;
                                        }
                                    }
                                }
                                grid(Control6150628)
                                {
                                    ShowCaption = false;
                                    group(Control6150619)
                                    {
                                        ShowCaption = false;
                                        field("Meta Description";"Meta Description")
                                        {
                                        }
                                    }
                                    group(Control6150616)
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
        CurrPage.MagentoCategoryLinks.PAGE.SetRootNo("Root Item Group No.");
    end;
}


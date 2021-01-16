page 6151439 "NPR Magento Store Item List"
{
    // MAG1.21/MHA /20151118  CASE 227354 Object created
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG9.00.2.11/TS  /20180301  CASE 305585 Added field Visibility.
    // MAG2.26/MHA /20200601  CASE 404580 Magento "Item Group" renamed to "Category"

    Caption = 'Webshops';
    PageType = ListPlus;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Store Item";

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
                            field("Item No."; "Item No.")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the Item No. field';
                            }
                            field(Webshop; Webshop)
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the Webshop field';
                            }
                            field("Store Code"; "Store Code")
                            {
                                ApplicationArea = All;
                                Editable = false;
                                ToolTip = 'Specifies the value of the Store Code field';
                            }
                            field("Website Code"; "Website Code")
                            {
                                ApplicationArea = All;
                                Editable = false;
                                ToolTip = 'Specifies the value of the Website Code field';
                            }
                            field(Enabled; Enabled)
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the Enabled field';

                                trigger OnValidate()
                                begin
                                    CurrPage.Update(true);
                                end;
                            }
                            field(GetEnabledFieldsCaption; GetEnabledFieldsCaption)
                            {
                                ApplicationArea = All;
                                Caption = 'Fields Enabled';
                                Editable = false;
                                ToolTip = 'Specifies the value of the Fields Enabled field';
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
                        part(MagentoCategoryLinks; "NPR Magento Category Links")
                        {
                            Caption = 'Magento Category Links';
                            SubPageLink = "Item No." = FIELD("Item No.");
                            ApplicationArea = All;
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
                                        field("Unit Price"; "Unit Price")
                                        {
                                            ApplicationArea = All;
                                            ToolTip = 'Specifies the value of the Unit Price field';
                                        }
                                    }
                                    group(Control6150687)
                                    {
                                        ShowCaption = false;
                                        field("Unit Price Enabled"; "Unit Price Enabled")
                                        {
                                            ApplicationArea = All;
                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Unit Price Enabled field';
                                        }
                                    }
                                }
                                grid(Control6150685)
                                {
                                    ShowCaption = false;
                                    group(Control6150686)
                                    {
                                        ShowCaption = false;
                                        field("Product New From"; "Product New From")
                                        {
                                            ApplicationArea = All;
                                            ToolTip = 'Specifies the value of the Product New From field';
                                        }
                                    }
                                    group(Control6150684)
                                    {
                                        ShowCaption = false;
                                        field("Product New From Enabled"; "Product New From Enabled")
                                        {
                                            ApplicationArea = All;
                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Product New From Enabled field';
                                        }
                                    }
                                }
                                grid(Control6150682)
                                {
                                    ShowCaption = false;
                                    group(Control6150679)
                                    {
                                        ShowCaption = false;
                                        field("Product New To"; "Product New To")
                                        {
                                            ApplicationArea = All;
                                            ToolTip = 'Specifies the value of the Product New To field';
                                        }
                                    }
                                    group(Control6150677)
                                    {
                                        ShowCaption = false;
                                        field("Product New To Enabled"; "Product New To Enabled")
                                        {
                                            ApplicationArea = All;
                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Product New To Enabled field';
                                        }
                                    }
                                }
                                grid(Control6150675)
                                {
                                    ShowCaption = false;
                                    group(Control6150676)
                                    {
                                        ShowCaption = false;
                                        field("Special Price"; "Special Price")
                                        {
                                            ApplicationArea = All;
                                            ToolTip = 'Specifies the value of the Special Price field';
                                        }
                                    }
                                    group(Control6150674)
                                    {
                                        ShowCaption = false;
                                        field("Special Price Enabled"; "Special Price Enabled")
                                        {
                                            ApplicationArea = All;
                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Special Price Enabled field';
                                        }
                                    }
                                }
                                grid(Control6150672)
                                {
                                    ShowCaption = false;
                                    group(Control6150669)
                                    {
                                        ShowCaption = false;
                                        field("Special Price From"; "Special Price From")
                                        {
                                            ApplicationArea = All;
                                            ToolTip = 'Specifies the value of the Special Price From field';
                                        }
                                    }
                                    group(Control6150667)
                                    {
                                        ShowCaption = false;
                                        field("Special Price From Enabled"; "Special Price From Enabled")
                                        {
                                            ApplicationArea = All;
                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Special Price From Enabled field';
                                        }
                                    }
                                }
                                grid(Control6150665)
                                {
                                    ShowCaption = false;
                                    group(Control6150666)
                                    {
                                        ShowCaption = false;
                                        field("Special Price To"; "Special Price To")
                                        {
                                            ApplicationArea = All;
                                            ToolTip = 'Specifies the value of the Special Price To field';
                                        }
                                    }
                                    group(Control6150664)
                                    {
                                        ShowCaption = false;
                                        field("Special Price To Enabled"; "Special Price To Enabled")
                                        {
                                            ApplicationArea = All;
                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Special Price To Enabled field';
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
                                        field("Webshop Name"; "Webshop Name")
                                        {
                                            ApplicationArea = All;
                                            Caption = 'Name';
                                            ToolTip = 'Specifies the value of the Name field';
                                        }
                                    }
                                    group(Control6150655)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Name Enabled"; "Webshop Name Enabled")
                                        {
                                            ApplicationArea = All;
                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Webshop Name Enabled field';
                                        }
                                    }
                                }
                                grid(Control6150651)
                                {
                                    ShowCaption = false;
                                    group(Control6150654)
                                    {
                                        ShowCaption = false;
                                        field("FORMAT(""Webshop Description"".HASVALUE)"; Format("Webshop Description".HasValue))
                                        {
                                            ApplicationArea = All;
                                            Caption = 'Description';
                                            ToolTip = 'Specifies the value of the Description field';

                                            trigger OnAssistEdit()
                                            var
                                                RecRef: RecordRef;
                                                FieldRef: FieldRef;
                                                MagentoFunctions: Codeunit "NPR Magento Functions";
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
                                        field("Webshop Description Enabled"; "Webshop Description Enabled")
                                        {
                                            ApplicationArea = All;
                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Webshop Description Enabled field';
                                        }
                                    }
                                }
                                grid(Control6150648)
                                {
                                    ShowCaption = false;
                                    group(Control6150645)
                                    {
                                        ShowCaption = false;
                                        field("FORMAT(""Webshop Short Desc."".HASVALUE)"; Format("Webshop Short Desc.".HasValue))
                                        {
                                            ApplicationArea = All;
                                            Caption = 'Short Description';
                                            ToolTip = 'Specifies the value of the Short Description field';

                                            trigger OnAssistEdit()
                                            var
                                                RecRef: RecordRef;
                                                FieldRef: FieldRef;
                                                MagentoFunctions: Codeunit "NPR Magento Functions";
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
                                        field("Webshop Short Desc. Enabled"; "Webshop Short Desc. Enabled")
                                        {
                                            ApplicationArea = All;
                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Webshop Short Description Enabled field';
                                        }
                                    }
                                }
                                grid(Control6151402)
                                {
                                    ShowCaption = false;
                                    group(Control6151400)
                                    {
                                        ShowCaption = false;
                                        field(Visibility; Visibility)
                                        {
                                            ApplicationArea = All;
                                            ToolTip = 'Specifies the value of the Visibility field';
                                        }
                                    }
                                }
                                grid(Control6150641)
                                {
                                    ShowCaption = false;
                                    group(Control6150642)
                                    {
                                        ShowCaption = false;
                                        field("Display Only"; "Display Only")
                                        {
                                            ApplicationArea = All;
                                            ToolTip = 'Specifies the value of the Display Only field';
                                        }
                                    }
                                    group(Control6150640)
                                    {
                                        ShowCaption = false;
                                        field("Display Only Enabled"; "Display Only Enabled")
                                        {
                                            ApplicationArea = All;
                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Display Only Enabled field';
                                        }
                                    }
                                }
                                grid(Control6150638)
                                {
                                    ShowCaption = false;
                                    group(Control6150635)
                                    {
                                        ShowCaption = false;
                                        field("Seo Link"; "Seo Link")
                                        {
                                            ApplicationArea = All;
                                            ToolTip = 'Specifies the value of the Seo Link field';
                                        }
                                    }
                                    group(Control6150633)
                                    {
                                        ShowCaption = false;
                                        field("Seo Link Enabled"; "Seo Link Enabled")
                                        {
                                            ApplicationArea = All;
                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Seo Link Enabled field';
                                        }
                                    }
                                }
                                grid(Control6150631)
                                {
                                    ShowCaption = false;
                                    group(Control6150632)
                                    {
                                        ShowCaption = false;
                                        field("Meta Title"; "Meta Title")
                                        {
                                            ApplicationArea = All;
                                            ToolTip = 'Specifies the value of the Meta Title field';
                                        }
                                    }
                                    group(Control6150630)
                                    {
                                        ShowCaption = false;
                                        field("Meta Title Enabled"; "Meta Title Enabled")
                                        {
                                            ApplicationArea = All;
                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Meta Title Enabled field';
                                        }
                                    }
                                }
                                grid(Control6150628)
                                {
                                    ShowCaption = false;
                                    group(Control6150619)
                                    {
                                        ShowCaption = false;
                                        field("Meta Description"; "Meta Description")
                                        {
                                            ApplicationArea = All;
                                            ToolTip = 'Specifies the value of the Meta Description field';
                                        }
                                    }
                                    group(Control6150616)
                                    {
                                        ShowCaption = false;
                                        field("Meta Description Enabled"; "Meta Description Enabled")
                                        {
                                            ApplicationArea = All;
                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Meta Description Enabled field';
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


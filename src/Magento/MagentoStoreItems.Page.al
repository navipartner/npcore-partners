page 6151445 "NPR Magento Store Items"
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
    SourceTable = "NPR Magento Store Item";
    SourceTableView = SORTING("Item No.", "Store Code");

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
                            field(Webshop; Webshop)
                            {
                                ApplicationArea = All;
                            }
                            field("Store Code"; "Store Code")
                            {
                                ApplicationArea = All;
                                Editable = false;
                            }
                            field("Website Code"; "Website Code")
                            {
                                ApplicationArea = All;
                                Editable = false;
                            }
                            field(Enabled; Enabled)
                            {
                                ApplicationArea = All;

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
                        part(MagentoItemGroupLinks; "NPR Magento Category Links")
                        {
                            SubPageLink = "Item No." = FIELD("Item No.");
                            ApplicationArea=All;
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
                                        field("Unit Price"; "Unit Price")
                                        {
                                            ApplicationArea = All;
                                        }
                                    }
                                    group(Control6150676)
                                    {
                                        ShowCaption = false;
                                        field("Unit Price Enabled"; "Unit Price Enabled")
                                        {
                                            ApplicationArea = All;
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
                                        field("Product New From"; "Product New From")
                                        {
                                            ApplicationArea = All;
                                        }
                                    }
                                    group(Control6150671)
                                    {
                                        ShowCaption = false;
                                        field("Product New From Enabled"; "Product New From Enabled")
                                        {
                                            ApplicationArea = All;
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
                                        field("Product New To"; "Product New To")
                                        {
                                            ApplicationArea = All;
                                        }
                                    }
                                    group(Control6150666)
                                    {
                                        ShowCaption = false;
                                        field("Product New To Enabled"; "Product New To Enabled")
                                        {
                                            ApplicationArea = All;
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
                                        field("Special Price"; "Special Price")
                                        {
                                            ApplicationArea = All;
                                        }
                                    }
                                    group(Control6150661)
                                    {
                                        ShowCaption = false;
                                        field("Special Price Enabled"; "Special Price Enabled")
                                        {
                                            ApplicationArea = All;
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
                                        field("Special Price From"; "Special Price From")
                                        {
                                            ApplicationArea = All;
                                        }
                                    }
                                    group(Control6150656)
                                    {
                                        ShowCaption = false;
                                        field("Special Price From Enabled"; "Special Price From Enabled")
                                        {
                                            ApplicationArea = All;
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
                                        field("Special Price To"; "Special Price To")
                                        {
                                            ApplicationArea = All;
                                        }
                                    }
                                    group(Control6150651)
                                    {
                                        ShowCaption = false;
                                        field("Special Price To Enabled"; "Special Price To Enabled")
                                        {
                                            ApplicationArea = All;
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
                                        field("Webshop Name"; "Webshop Name")
                                        {
                                            ApplicationArea = All;
                                            Caption = 'Name';
                                        }
                                    }
                                    group(Control6150644)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Name Enabled"; "Webshop Name Enabled")
                                        {
                                            ApplicationArea = All;
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
                                        field("FORMAT(""Webshop Description"".HASVALUE)"; Format("Webshop Description".HasValue))
                                        {
                                            ApplicationArea = All;
                                            Caption = 'Description';

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
                                    group(Control6150639)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Description Enabled"; "Webshop Description Enabled")
                                        {
                                            ApplicationArea = All;
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
                                        field("FORMAT(""Webshop Short Desc."".HASVALUE)"; Format("Webshop Short Desc.".HasValue))
                                        {
                                            ApplicationArea = All;
                                            Caption = 'Short Description';

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
                                    group(Control6150634)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Short Desc. Enabled"; "Webshop Short Desc. Enabled")
                                        {
                                            ApplicationArea = All;
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
                                        field(Visibility; Visibility)
                                        {
                                            ApplicationArea = All;
                                        }
                                    }
                                }
                                grid(Control6150632)
                                {
                                    ShowCaption = false;
                                    group(Control6150631)
                                    {
                                        ShowCaption = false;
                                        field("Display Only"; "Display Only")
                                        {
                                            ApplicationArea = All;
                                        }
                                    }
                                    group(Control6150629)
                                    {
                                        ShowCaption = false;
                                        field("Display Only Enabled"; "Display Only Enabled")
                                        {
                                            ApplicationArea = All;
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
                                        field("Seo Link"; "Seo Link")
                                        {
                                            ApplicationArea = All;
                                        }
                                    }
                                    group(Control6150624)
                                    {
                                        ShowCaption = false;
                                        field("Seo Link Enabled"; "Seo Link Enabled")
                                        {
                                            ApplicationArea = All;
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
                                        field("Meta Title"; "Meta Title")
                                        {
                                            ApplicationArea = All;
                                        }
                                    }
                                    group(Control6150619)
                                    {
                                        ShowCaption = false;
                                        field("Meta Title Enabled"; "Meta Title Enabled")
                                        {
                                            ApplicationArea = All;
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
                                        field("Meta Description"; "Meta Description")
                                        {
                                            ApplicationArea = All;
                                        }
                                    }
                                    group(Control6150614)
                                    {
                                        ShowCaption = false;
                                        field("Meta Description Enabled"; "Meta Description Enabled")
                                        {
                                            ApplicationArea = All;
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


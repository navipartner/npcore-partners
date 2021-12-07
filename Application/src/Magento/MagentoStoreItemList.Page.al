page 6151439 "NPR Magento Store Item List"
{
    Caption = 'Webshops';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Store Item";
    ApplicationArea = NPRRetail;

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
                            field("Item No."; Rec."Item No.")
                            {

                                ToolTip = 'Specifies the value of the Item No. field';
                                ApplicationArea = NPRRetail;
                            }
                            field(Webshop; Rec.Webshop)
                            {

                                ToolTip = 'Specifies the value of the Webshop field';
                                ApplicationArea = NPRRetail;
                            }
                            field("Store Code"; Rec."Store Code")
                            {

                                Editable = false;
                                ToolTip = 'Specifies the value of the Store Code field';
                                ApplicationArea = NPRRetail;
                            }
                            field("Website Code"; Rec."Website Code")
                            {

                                Editable = false;
                                ToolTip = 'Specifies the value of the Website Code field';
                                ApplicationArea = NPRRetail;
                            }
                            field(Enabled; Rec.Enabled)
                            {

                                ToolTip = 'Specifies the value of the Enabled field';
                                ApplicationArea = NPRRetail;

                                trigger OnValidate()
                                begin
                                    CurrPage.Update(true);
                                end;
                            }
                            field(GetEnabledFieldsCaption; Rec.GetEnabledFieldsCaption())
                            {

                                Caption = 'Fields Enabled';
                                Editable = false;
                                ToolTip = 'Specifies the value of the Fields Enabled field';
                                ApplicationArea = NPRRetail;
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
                            ApplicationArea = NPRRetail;

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
                                        field("Unit Price"; Rec."Unit Price")
                                        {

                                            ToolTip = 'Specifies the value of the Unit Price field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                    group(Control6150687)
                                    {
                                        ShowCaption = false;
                                        field("Unit Price Enabled"; Rec."Unit Price Enabled")
                                        {

                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Unit Price Enabled field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                }
                                grid(Control6150685)
                                {
                                    ShowCaption = false;
                                    group(Control6150686)
                                    {
                                        ShowCaption = false;
                                        field("Product New From"; Rec."Product New From")
                                        {

                                            ToolTip = 'Specifies the value of the Product New From field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                    group(Control6150684)
                                    {
                                        ShowCaption = false;
                                        field("Product New From Enabled"; Rec."Product New From Enabled")
                                        {

                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Product New From Enabled field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                }
                                grid(Control6150682)
                                {
                                    ShowCaption = false;
                                    group(Control6150679)
                                    {
                                        ShowCaption = false;
                                        field("Product New To"; Rec."Product New To")
                                        {

                                            ToolTip = 'Specifies the value of the Product New To field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                    group(Control6150677)
                                    {
                                        ShowCaption = false;
                                        field("Product New To Enabled"; Rec."Product New To Enabled")
                                        {

                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Product New To Enabled field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                }
                                grid(Control6150675)
                                {
                                    ShowCaption = false;
                                    group(Control6150676)
                                    {
                                        ShowCaption = false;
                                        field("Special Price"; Rec."Special Price")
                                        {

                                            ToolTip = 'Specifies the value of the Special Price field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                    group(Control6150674)
                                    {
                                        ShowCaption = false;
                                        field("Special Price Enabled"; Rec."Special Price Enabled")
                                        {

                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Special Price Enabled field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                }
                                grid(Control6150672)
                                {
                                    ShowCaption = false;
                                    group(Control6150669)
                                    {
                                        ShowCaption = false;
                                        field("Special Price From"; Rec."Special Price From")
                                        {

                                            ToolTip = 'Specifies the value of the Special Price From field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                    group(Control6150667)
                                    {
                                        ShowCaption = false;
                                        field("Special Price From Enabled"; Rec."Special Price From Enabled")
                                        {

                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Special Price From Enabled field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                }
                                grid(Control6150665)
                                {
                                    ShowCaption = false;
                                    group(Control6150666)
                                    {
                                        ShowCaption = false;
                                        field("Special Price To"; Rec."Special Price To")
                                        {

                                            ToolTip = 'Specifies the value of the Special Price To field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                    group(Control6150664)
                                    {
                                        ShowCaption = false;
                                        field("Special Price To Enabled"; Rec."Special Price To Enabled")
                                        {

                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Special Price To Enabled field';
                                            ApplicationArea = NPRRetail;
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
                                        field("Webshop Name"; Rec."Webshop Name")
                                        {

                                            Caption = 'Name';
                                            ToolTip = 'Specifies the value of the Name field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                    group(Control6150655)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Name Enabled"; Rec."Webshop Name Enabled")
                                        {

                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Webshop Name Enabled field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                }
                                grid(Control6150651)
                                {
                                    ShowCaption = false;
                                    group(Control6150654)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Description"; Format(Rec."Webshop Description".HasValue))
                                        {

                                            Caption = 'Description';
                                            ToolTip = 'Specifies the value of the Description field';
                                            ApplicationArea = NPRRetail;

                                            trigger OnAssistEdit()
                                            var
                                                MagentoFunctions: Codeunit "NPR Magento Functions";
                                                TempBlob: Codeunit "Temp Blob";
                                                OutStr: OutStream;
                                                InStr: InStream;
                                            begin
                                                TempBlob.CreateOutStream(OutStr);
                                                Rec."Webshop Description".CreateInStream(InStr);
                                                CopyStream(OutStr, InStr);
                                                if MagentoFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                                                    if TempBlob.HasValue() then begin
                                                        TempBlob.CreateInStream(InStr);
                                                        Rec."Webshop Description".CreateOutStream(OutStr);
                                                        CopyStream(OutStr, InStr);
                                                    end else
                                                        Clear(Rec."Webshop Description");
                                                    Rec.Modify(true);
                                                end;
                                            end;
                                        }
                                    }
                                    group(Control6150650)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Description Enabled"; Rec."Webshop Description Enabled")
                                        {

                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Webshop Description Enabled field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                }
                                grid(Control6150648)
                                {
                                    ShowCaption = false;
                                    group(Control6150645)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Short Description"; Format(Rec."Webshop Short Desc.".HasValue))
                                        {

                                            Caption = 'Short Description';
                                            ToolTip = 'Specifies the value of the Short Description field';
                                            ApplicationArea = NPRRetail;

                                            trigger OnAssistEdit()
                                            var
                                                MagentoFunctions: Codeunit "NPR Magento Functions";
                                                TempBlob: Codeunit "Temp Blob";
                                                OutStr: OutStream;
                                                InStr: InStream;
                                            begin
                                                TempBlob.CreateOutStream(OutStr);
                                                Rec."Webshop Short Desc.".CreateInStream(InStr);
                                                CopyStream(OutStr, InStr);
                                                if MagentoFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                                                    if TempBlob.HasValue() then begin
                                                        TempBlob.CreateInStream(InStr);
                                                        Rec."Webshop Short Desc.".CreateOutStream(OutStr);
                                                        CopyStream(OutStr, InStr);
                                                    end else
                                                        Clear(Rec."Webshop Short Desc.");
                                                    Rec.Modify(true);
                                                end;
                                            end;
                                        }
                                    }
                                    group(Control6150643)
                                    {
                                        ShowCaption = false;
                                        field("Webshop Short Desc. Enabled"; Rec."Webshop Short Desc. Enabled")
                                        {

                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Webshop Short Description Enabled field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                }
                                grid(Control6151402)
                                {
                                    ShowCaption = false;
                                    group(Control6151400)
                                    {
                                        ShowCaption = false;
                                        field(Visibility; Rec.Visibility)
                                        {

                                            ToolTip = 'Specifies the value of the Visibility field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                }
                                grid(Control6150641)
                                {
                                    ShowCaption = false;
                                    group(Control6150642)
                                    {
                                        ShowCaption = false;
                                        field("Display Only"; Rec."Display Only")
                                        {

                                            ToolTip = 'Specifies the value of the Display Only field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                    group(Control6150640)
                                    {
                                        ShowCaption = false;
                                        field("Display Only Enabled"; Rec."Display Only Enabled")
                                        {

                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Display Only Enabled field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                }
                                grid(Control6150638)
                                {
                                    ShowCaption = false;
                                    group(Control6150635)
                                    {
                                        ShowCaption = false;
                                        field("Seo Link"; Rec."Seo Link")
                                        {

                                            ToolTip = 'Specifies the value of the Seo Link field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                    group(Control6150633)
                                    {
                                        ShowCaption = false;
                                        field("Seo Link Enabled"; Rec."Seo Link Enabled")
                                        {

                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Seo Link Enabled field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                }
                                grid(Control6150631)
                                {
                                    ShowCaption = false;
                                    group(Control6150632)
                                    {
                                        ShowCaption = false;
                                        field("Meta Title"; Rec."Meta Title")
                                        {

                                            ToolTip = 'Specifies the value of the Meta Title field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                    group(Control6150630)
                                    {
                                        ShowCaption = false;
                                        field("Meta Title Enabled"; Rec."Meta Title Enabled")
                                        {

                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Meta Title Enabled field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                }
                                grid(Control6150628)
                                {
                                    ShowCaption = false;
                                    group(Control6150619)
                                    {
                                        ShowCaption = false;
                                        field("Meta Description"; Rec."Meta Description")
                                        {

                                            ToolTip = 'Specifies the value of the Meta Description field';
                                            ApplicationArea = NPRRetail;
                                        }
                                    }
                                    group(Control6150616)
                                    {
                                        ShowCaption = false;
                                        field("Meta Description Enabled"; Rec."Meta Description Enabled")
                                        {

                                            ShowCaption = false;
                                            ToolTip = 'Specifies the value of the Meta Description Enabled field';
                                            ApplicationArea = NPRRetail;
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

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.MagentoCategoryLinks.PAGE.SetRootNo(Rec."Root Item Group No.");
    end;
}
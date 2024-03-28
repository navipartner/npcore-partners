page 6184569 "NPR RS POPDV Records"
{
    Extensible = false;
    ApplicationArea = NPRRSLocal;
    UsageCategory = Documents;
    Caption = 'RS POPDV Records';
    DataCaptionExpression = PageCaptionTxt;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,XML';
    SourceTable = "NPR VAT EV Entry";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(Dates)
            {
                Caption = 'Dates';
                field(StartDate; StartDate)
                {
                    Caption = 'Start Date';
                    ToolTip = 'Specifies the value of the Start Date field.';
                    Editable = false;
                    ApplicationArea = NPRRSLocal;
                }
                field(EndDate; EndDate)
                {
                    Caption = 'End Date';
                    ToolTip = 'Specifies the value of the End Date field.';
                    Editable = false;
                    ApplicationArea = NPRRSLocal;
                }
            }
            group(Group1)
            {
                Caption = 'EV 1';
                group("Group1-1")
                {
                    ShowCaption = false;
                    grid("HeaderGrid1")
                    {
                        ShowCaption = false;
                        field(Caption1_HeadingLbl; Caption1_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field(ValueCaption1Lbl; ValueCaptionLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid1_1")
                    {
                        ShowCaption = false;
                        field(Caption1_1; Caption1_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 1_1"; Rec."Field 1_1")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 1_1"));
                            end;
                        }
                    }
                    grid("Grid1_2")
                    {
                        ShowCaption = false;
                        field(Caption1_2; Caption1_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 1_2"; Rec."Field 1_2")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 1_2"));
                            end;
                        }
                    }
                    grid("Grid1_3")
                    {
                        ShowCaption = false;
                        field(Caption1_3; Caption1_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 1_3"; Rec."Field 1_3")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 1_3"));
                            end;
                        }
                    }
                    grid("Grid1_4")
                    {
                        ShowCaption = false;
                        field(Caption1_4; Caption1_4Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 1_4"; Rec."Field 1_4")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 1_4"));
                            end;
                        }
                    }
                    grid("Grid1_5")
                    {
                        ShowCaption = false;
                        field(Caption1_5; Caption1_5Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 1_5"; Rec."Field 1_5")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid1_6")
                    {
                        ShowCaption = false;
                        field(Caption1_6; Caption1_6Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 1_6"; Rec."Field 1_6")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 1_6"));
                            end;
                        }
                    }
                    grid("Grid1_7")
                    {
                        ShowCaption = false;
                        field(Caption1_7; Caption1_7Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 1_7"; Rec."Field 1_7")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 1_7"));
                            end;
                        }
                    }
                }
            }
            group(Group2)
            {
                Caption = 'EV 2';
                group("Group2-1")
                {
                    ShowCaption = false;
                    grid("HeaderGrid2")
                    {
                        ShowCaption = false;
                        field(Caption2_HeadingLbl; Caption2_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field(ValueCaption2Lbl; ValueCaptionLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid2_1")
                    {
                        ShowCaption = false;
                        field(Caption2_1; Caption2_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 2_1"; Rec."Field 2_1")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 2_1"));
                            end;
                        }
                    }
                    grid("Grid2_2")
                    {
                        ShowCaption = false;
                        field(Caption2_2; Caption2_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 2_2"; Rec."Field 2_2")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 2_2"));
                            end;
                        }
                    }
                    grid("Grid2_3")
                    {
                        ShowCaption = false;
                        field(Caption2_3; Caption2_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 2_3"; Rec."Field 2_3")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 2_3"));
                            end;
                        }
                    }
                    grid("Grid2_4")
                    {
                        ShowCaption = false;
                        field(Caption2_4; Caption2_4Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 2_4"; Rec."Field 2_4")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 2_4"));
                            end;
                        }
                    }
                    grid("Grid2_5")
                    {
                        ShowCaption = false;
                        field(Caption2_5; Caption2_5Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 2_5"; Rec."Field 2_5")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid2_6")
                    {
                        ShowCaption = false;
                        field(Caption2_6; Caption2_6Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 2_6"; Rec."Field 2_6")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 2_6"));
                            end;
                        }
                    }
                    grid("Grid2_7")
                    {
                        ShowCaption = false;
                        field(Caption2_7; Caption2_7Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 2_7"; Rec."Field 2_7")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 2_7"));
                            end;
                        }
                    }
                }
            }
            group(Group3)
            {
                Caption = 'EV 3';
                group("Group3-1")
                {
                    ShowCaption = false;

                    grid("AboveHeaderGrid3")
                    {
                        ShowCaption = false;
                        field(DummyCaptionLbl; DummyCaptionLbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid(AboveHeaderGridRight)
                        {
                            field(GeneralRateCaptionLbl; GeneralRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(SpecialRateCaptionLbl; SpecialRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("HeaderGrid3")
                    {
                        ShowCaption = false;
                        field(Caption3_HeadingLbl; Caption3_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid(HeaderGridRight)
                        {
                            field(BaseCaption; BaseCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(AmountCaption; AmountCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(BaseCaption2; BaseCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(AmountCaption2; AmountCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid3-1")
                    {
                        ShowCaption = false;
                        field(Caption3_1; Caption3_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3-1Right")
                        {
                            field("Field 3_1_1"; Rec."Field 3_1_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_1_1"));
                                end;
                            }
                            field("Field 3_1_2"; Rec."Field 3_1_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_1_2"));
                                end;
                            }
                            field("Field 3_1_3"; Rec."Field 3_1_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_1_3"));
                                end;
                            }
                            field("Field 3_1_4"; Rec."Field 3_1_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_1_4"));
                                end;
                            }
                        }
                    }
                    grid("Grid3-2")
                    {
                        field(Caption3_2; Caption3_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3-2Right")
                        {
                            field("Field 3_2_1"; Rec."Field 3_2_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_2_1"));
                                end;
                            }
                            field("Field 3_2_2"; Rec."Field 3_2_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_2_2"));
                                end;
                            }
                            field("Field 3_2_3"; Rec."Field 3_2_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_2_3"));
                                end;
                            }
                            field("Field 3_2_4"; Rec."Field 3_2_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_2_4"));
                                end;
                            }
                        }
                    }
                    grid("Grid3-3")
                    {
                        field(Caption3_3; Caption3_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3-3Right")
                        {
                            field("Field 3_3_1"; Rec."Field 3_3_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_3_1"));
                                end;
                            }
                            field("Field 3_3_2"; Rec."Field 3_3_2")
                            {
                                ShowCaption = false;
                                BlankZero = true;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 3_3_3"; Rec."Field 3_3_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_3_3"));
                                end;
                            }
                            field("Field 3_3_4"; Rec."Field 3_3_4")
                            {
                                ShowCaption = false;
                                BlankZero = true;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid3-4")
                    {
                        field(Caption3_4; Caption3_4Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3-4Right")
                        {
                            field("Field 3_4_1"; Rec."Field 3_4_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_4_1"));
                                end;
                            }
                            field("Field 3_4_2"; Rec."Field 3_4_2")
                            {
                                ShowCaption = false;
                                BlankZero = true;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 3_4_3"; Rec."Field 3_4_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_4_3"));
                                end;
                            }
                            field("Field 3_4_4"; Rec."Field 3_4_4")
                            {
                                ShowCaption = false;
                                BlankZero = true;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid3-5")
                    {
                        field(Caption3_5; Caption3_5Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3-5Right")
                        {
                            field("Field 3_5_1"; Rec."Field 3_5_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_5_1"));
                                end;
                            }
                            field("Field 3_5_2"; Rec."Field 3_5_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_5_2"));
                                end;
                            }
                            field("Field 3_5_3"; Rec."Field 3_5_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_5_3"));
                                end;
                            }
                            field("Field 3_5_4"; Rec."Field 3_5_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_5_4"));
                                end;
                            }
                        }
                    }
                    grid("Grid3-6")
                    {
                        field(Caption3_6; Caption3_6Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3-6Right")
                        {
                            field("Field 3_6_1"; Rec."Field 3_6_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_6_1"));
                                end;
                            }
                            field("Field 3_6_2"; Rec."Field 3_6_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_6_2"));
                                end;
                            }
                            field("Field 3_6_3"; Rec."Field 3_6_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_6_3"));
                                end;
                            }
                            field("Field 3_6_4"; Rec."Field 3_6_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_6_4"));
                                end;
                            }
                        }
                    }
                    grid("Grid3-7")
                    {
                        field(Caption3_7; Caption3_7Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3-7Right")
                        {
                            field("Field 3_7_1"; Rec."Field 3_7_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_7_1"));
                                end;
                            }
                            field("Field 3_7_2"; Rec."Field 3_7_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_7_2"));
                                end;
                            }
                            field("Field 3_7_3"; Rec."Field 3_7_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_7_3"));
                                end;
                            }
                            field("Field 3_7_4"; Rec."Field 3_7_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_7_4"));
                                end;
                            }
                        }
                    }
                    grid("Grid3-8")
                    {
                        field(Caption3_8; Caption3_8Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3-8Right")
                        {
                            field("Field 3_8_1"; Rec."Field 3_8_1")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 3_8_2"; Rec."Field 3_8_2")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 3_8_3"; Rec."Field 3_8_3")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 3_8_4"; Rec."Field 3_8_4")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid3-9")
                    {
                        field(Caption3_9; Caption3_9Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3-9Right")
                        {
                            field("Field 3_9_1"; Rec."Field 3_9_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_9_1"));
                                end;
                            }
                            field("Field 3_9_2"; Rec."Field 3_9_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_9_2"));
                                end;
                            }
                            field("Field 3_9_3"; Rec."Field 3_9_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_9_3"));
                                end;
                            }
                            field("Field 3_9_4"; Rec."Field 3_9_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3_9_4"));
                                end;
                            }
                        }
                    }
                    grid("Grid3-10")
                    {
                        field(Caption3_10; Caption3_10Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3-10Right")
                        {
                            field("Field 3_10_2"; Rec."Field 3_10_2")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 3_10_4"; Rec."Field 3_10_4")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                }
            }
            group(Group3a)
            {
                Caption = 'EV 3a';
                group("Group3a-1")
                {
                    ShowCaption = false;

                    grid("AboveHeaderGrid3a")
                    {
                        ShowCaption = false;
                        field(DummyCaption3aLbl; DummyCaptionLbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid(AboveHeaderGrid3aRight)
                        {
                            field(GeneralRateCaptionLbl3a; GeneralRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(SpecialRateCaptionLbl3a; SpecialRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("HeaderGrid3a")
                    {
                        ShowCaption = false;
                        field(Caption3a_HeadingLbl; Caption3a_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid(HeaderGrid3aRight)
                        {
                            field(AmountCaption3a; AmountCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(AmountCaption3a2; AmountCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid3a-1")
                    {
                        ShowCaption = false;
                        field(Caption3a_1; Caption3a_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3a-1Right")
                        {
                            field("Field 3a_1_1"; Rec."Field 3a_1_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_1_1"));
                                end;
                            }
                            field("Field 3a_1_2"; Rec."Field 3a_1_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_1_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid3a-2")
                    {
                        field(Caption3a_2; Caption3a_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3a-2Right")
                        {
                            field("Field 3a_2_1"; Rec."Field 3a_2_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_2_1"));
                                end;
                            }
                            field("Field 3a_2_2"; Rec."Field 3a_2_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_2_1"));
                                end;
                            }
                        }
                    }
                    grid("Grid3a-3")
                    {
                        field(Caption3a_3; Caption3a_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3a-3Right")
                        {
                            field("Field 3a_3_1"; Rec."Field 3a_3_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_3_1"));
                                end;
                            }
                            field("Field 3a_3_2"; Rec."Field 3a_3_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_3_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid3a-4")
                    {
                        field(Caption3a_4; Caption3a_4Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3a-4Right")
                        {
                            field("Field 3a_4_1"; Rec."Field 3a_4_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_4_1"));
                                end;
                            }
                            field("Field 3a_4_2"; Rec."Field 3a_4_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_4_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid3a-5")
                    {
                        field(Caption3a_5; Caption3a_5Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3a-5Right")
                        {
                            field("Field 3a_5_1"; Rec."Field 3a_5_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_5_1"));
                                end;
                            }
                            field("Field 3a_5_2"; Rec."Field 3a_5_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_5_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid3a-6")
                    {
                        field(Caption3a_6; Caption3a_6Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3a-6Right")
                        {
                            field("Field 3a_6_1"; Rec."Field 3a_6_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_6_1"));
                                end;
                            }
                            field("Field 3a_6_2"; Rec."Field 3a_6_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_6_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid3a-7")
                    {
                        field(Caption3a_7; Caption3a_7Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3a-7Right")
                        {
                            field("Field 3a_7_1"; Rec."Field 3a_7_1")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 3a_7_2"; Rec."Field 3a_7_2")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid3a-8")
                    {
                        field(Caption3a_8; Caption3a_8Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3a-8Right")
                        {
                            field("Field 3a_8_1"; Rec."Field 3a_8_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_8_1"));
                                end;
                            }
                            field("Field 3a_8_2"; Rec."Field 3a_8_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 3a_8_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid3a-9")
                    {
                        field(Caption3a_9; Caption3a_9Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid3a-9Right")
                        {
                            field("Field 3a_9_1"; Rec."Field 3a_9_1")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 3a_9_2"; Rec."Field 3a_9_2")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                }
            }
            group(Group4)
            {
                Caption = 'EV 4';
                group("Group4-1")
                {
                    ShowCaption = false;
                    grid("AboveHeaderGrid4")
                    {
                        ShowCaption = false;
                        field(Caption4_HeadingLbl; Caption4_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("HeaderGrid4")
                    {
                        ShowCaption = false;
                        field(Caption4_1_HeadingLbl; Caption4_1_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid(HeaderGrid4Right)
                        {
                            field(DetermingBaseCaptionLbl; DetermingBaseCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(AmountCaption42; AmountCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid4-1")
                    {
                        ShowCaption = false;
                        field(Caption4_1_1; Caption4_1_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid4-1Right")
                        {
                            field("Field 4_1_1"; Rec."Field 4_1_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 4_1_1"));
                                end;
                            }
                            field(DummyCaption4_1_1Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid4-2")
                    {
                        field(Caption4_1_2; Caption4_1_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid4-2Right")
                        {
                            field("Field 4_2_1"; Rec."Field 4_1_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 4_1_2"));
                                end;
                            }
                            field(DummyCaption4_1_2Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid4-3")
                    {
                        field(Caption4_3; Caption4_1_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid4-3Right")
                        {
                            field("Field 4_1_3"; Rec."Field 4_1_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 4_1_3"));
                                end;
                            }
                            field(DummyCaption4_1_3Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid4-4")
                    {
                        field(Caption4_4; Caption4_1_4Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid4-4Right")
                        {
                            field(DummyCaption4_1_4Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 4_1_4_2"; Rec."Field 4_1_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 4_1_4"));
                                end;
                            }
                        }
                    }
                    grid("HeaderGrid4_2_Above")
                    {
                        ShowCaption = false;
                        field(DummyCaption4_2Lbl; DummyCaptionLbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid(HeaderGrid4RightAbove)
                        {
                            field(DetermingBaseCaption4_2Lbl; DetermingBaseCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(AmountCaption4_2; AmountCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("HeaderGrid4_2")
                    {
                        ShowCaption = false;
                        field(Caption4_2_HeadingLbl; Caption4_2_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid(HeaderGrid4_2Right)
                        {
                            field(GeneralRateCaptionLbl4_2; GeneralRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(SpecialRateCaptionLbl4_2; SpecialRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(GeneralRateCaptionLbl4_2_2; GeneralRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(SpecialRateCaptionLbl4_2_2; SpecialRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid4-2-1")
                    {
                        field(Caption4_2_1Lbl; Caption4_2_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid4-2-1Right")
                        {
                            field("Field 4_2_1_1"; Rec."Field 4_2_1_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 4_2_1_1"));
                                end;
                            }
                            field("Field 4_2_1_2"; Rec."Field 4_2_1_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 4_2_1_2"));
                                end;
                            }
                            field(DummyCaption4_2_1_3Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(DummyCaption4_2_1_4Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid4-2-2")
                    {
                        field(Caption4_2_2Lbl; Caption4_2_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid4-2-2Right")
                        {
                            field("Field 4_2_2_1"; Rec."Field 4_2_2_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 4_2_2_1"));
                                end;
                            }
                            field("Field 4_2_2_2"; Rec."Field 4_2_2_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 4_2_2_2"));
                                end;
                            }
                            field(DummyCaption4_2_2_3Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(DummyCaption4_2_2_4Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid4-2-3")
                    {
                        field(Caption4_2_3Lbl; Caption4_2_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid4-2-3Right")
                        {
                            field("Field 4_2_3_1"; Rec."Field 4_2_3_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 4_2_3_1"));
                                end;
                            }
                            field("Field 4_2_3_2"; Rec."Field 4_2_3_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 4_2_3_2"));
                                end;
                            }
                            field(DummyCaption4_2_3_3Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(DummyCaption4_2_3_4Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid4-2-4")
                    {
                        field(Caption4_2_4Lbl; Caption4_2_4Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid4-2-4Right")
                        {
                            field(DummyCaption4_2_4_1Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(DummyCaption4_2_4_2Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 4_2_4_3"; Rec."Field 4_2_4_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 4_2_4_3"));
                                end;
                            }
                            field("Field 4_2_4_4"; Rec."Field 4_2_4_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 4_2_4_3"));
                                end;
                            }
                        }
                    }
                }
            }
            group(Group5)
            {
                Caption = 'EV 5';
                group("Group5-1")
                {
                    ShowCaption = false;
                    grid("HeaderGrid5")
                    {
                        ShowCaption = false;
                        field(Caption5_HeadingLbl; Caption5_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field(ValueCaption5Lbl; Value2CaptionLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid5_1")
                    {
                        ShowCaption = false;
                        field(Caption5_1; Caption5_1Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 5_1"; Rec."Field 5_1")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid5_2")
                    {
                        ShowCaption = false;
                        field(Caption5_2; Caption5_2Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 5_2"; Rec."Field 5_2")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid5_3")
                    {
                        ShowCaption = false;
                        field(Caption5_3; Caption5_3Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 5_3"; Rec."Field 5_3")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid5_4")
                    {
                        ShowCaption = false;
                        field(Caption5_4; Caption5_4Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 5_4"; Rec."Field 5_4")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid5_5")
                    {
                        ShowCaption = false;
                        field(Caption5_5; Caption5_5Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 5_5"; Rec."Field 5_5")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid5_6")
                    {
                        ShowCaption = false;
                        field(Caption5_6; Caption5_6Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 5_6"; Rec."Field 5_6")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid5_7")
                    {
                        ShowCaption = false;
                        field(Caption5_7; Caption5_7Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 5_7"; Rec."Field 5_7")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                }
            }
            group(Group6)
            {
                Caption = 'EV 6';
                group("Group6-1")
                {
                    ShowCaption = false;
                    grid("AboveHeaderGrid6")
                    {
                        ShowCaption = false;
                        field(Caption6_HeadingLbl; Caption6_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid6-1")
                    {
                        ShowCaption = false;
                        field(Caption6_1Lbl; Caption6_1Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 6_1"; Rec."Field 6_1")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 6_1"));
                            end;
                        }
                    }
                    grid("Grid6-2")
                    {
                        ShowCaption = false;
                        field(Caption6_2Lbl; Caption6_2Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid6-2Right")
                        {
                            field(GeneralRateCaption6_2Lbl; GeneralRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(SpecialRateCaption6_2Lbl; SpecialRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid6-2-1")
                    {
                        ShowCaption = false;
                        field(Caption6_2_1Lbl; Caption6_2_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid6-2-1Right")
                        {
                            field("Field 6_2_1_1"; Rec."Field 6_2_1_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 6_2_1_1"));
                                end;
                            }
                            field("Field 6_2_1_2"; Rec."Field 6_2_1_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 6_2_1_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid6-2-2")
                    {
                        ShowCaption = false;
                        field(Caption6_2_2Lbl; Caption6_2_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid6-2-2Right")
                        {
                            field("Field 6_2_2_1"; Rec."Field 6_2_2_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 6_2_2_1"));
                                end;
                            }
                            field("Field 6_2_2_2"; Rec."Field 6_2_2_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 6_2_2_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid6-2-3")
                    {
                        ShowCaption = false;
                        field(Caption6_2_3Lbl; Caption6_2_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid6-2-3Right")
                        {
                            field("Field 6_2_3_1"; Rec."Field 6_2_3_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 6_2_3_1"));
                                end;
                            }
                            field("Field 6_2_3_2"; Rec."Field 6_2_3_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 6_2_3_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid6-3")
                    {
                        ShowCaption = false;
                        field(Caption6_3Lbl; Caption6_3Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 6_3"; Rec."Field 6_3")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid6-4")
                    {
                        ShowCaption = false;
                        field(Caption6_4Lbl; Caption6_4Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 6_4"; Rec."Field 6_4")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 6_4"));
                            end;
                        }
                    }
                }
            }
            group(Group7)
            {
                Caption = 'EV 7';
                group("Group7-1")
                {
                    ShowCaption = false;
                    grid("AboveHeaderGrid7")
                    {
                        ShowCaption = false;
                        field(Caption7_HeadingLbl; Caption7_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("AboveHeaderGrid7-Right")
                        {
                            ShowCaption = false;
                            field(ValueOfCaptionLbl; ValueOfCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(AmountCaption7Lbl; AmountCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid7-1")
                    {
                        ShowCaption = false;
                        field(Caption7_1Lbl; Caption7_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid7-1Right")
                        {
                            field("Field 7_1_1"; Rec."Field 7_1_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 7_1_1"));
                                end;
                            }
                            field(DummyCaption7_1Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid7-2")
                    {
                        ShowCaption = false;
                        field(Caption7_2Lbl; Caption7_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid7-2Right")
                        {
                            field("Field 7_2_1"; Rec."Field 7_2_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 7_2_1"));
                                end;
                            }
                            field(DummyCaption7_2Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid7-3")
                    {
                        ShowCaption = false;
                        field(Caption7_3Lbl; Caption7_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid7-3Right")
                        {
                            field(DummyCaption7_3Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 7_3_1"; Rec."Field 7_3_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 7_3_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid7-4")
                    {
                        ShowCaption = false;
                        field(Caption7_4Lbl; Caption7_4Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid7-4Right")
                        {
                            field(DummyCaption7_4Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 7_4_2"; Rec."Field 7_4_2")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 7_4_2"));
                                end;
                            }
                        }
                    }
                }
            }
            group(Group8a)
            {
                Caption = 'EV 8a';
                group(Group8a_Inside)
                {
                    ShowCaption = false;

                    grid("HeaderGrid8")
                    {
                        ShowCaption = false;
                        field(Caption8_HeadingLbl; Caption8_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("AboveHeaderGrid8")
                    {
                        ShowCaption = false;
                        field(DummyCaption8Lbl; DummyCaptionLbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid(AboveHeaderGrid8Right)
                        {
                            field(GeneralRateCaption8aLbl; GeneralRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(SpecialRateCaption8aLbl; SpecialRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("HeaderGrid8a")
                    {
                        ShowCaption = false;
                        field(Caption8a_HeadingLbl; Caption8a_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid(HeaderGrid8aRight)
                        {
                            field(BaseCaption8a; BaseCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(AmountCaption8a; AmountCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(BaseCaption28a; BaseCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(AmountCaption28a; AmountCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid8-1")
                    {
                        ShowCaption = false;
                        field(Caption8a_1; Caption8a_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8-1Right")
                        {
                            field("Field 8a_1_1"; Rec."Field 8a_1_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_1_1"));
                                end;
                            }
                            field("Field 8a_1_2"; Rec."Field 8a_1_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_1_2"));
                                end;
                            }
                            field("Field 8a_1_3"; Rec."Field 8a_1_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_1_3"));
                                end;
                            }
                            field("Field 8a_1_4"; Rec."Field 8a_1_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_1_4"));
                                end;
                            }
                        }
                    }
                    grid("Grid8-2")
                    {
                        field(Caption8a_2; Caption8a_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8-2Right")
                        {
                            field("Field 8a_2_1"; Rec."Field 8a_2_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_2_1"));
                                end;
                            }
                            field("Field 8a_2_2"; Rec."Field 8a_2_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_2_1"));
                                end;
                            }
                            field("Field 8a_2_3"; Rec."Field 8a_2_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_2_1"));
                                end;
                            }
                            field("Field 8a_2_4"; Rec."Field 8a_2_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_2_1"));
                                end;
                            }
                        }
                    }
                    grid("Grid8-3")
                    {
                        field(Caption8a_3; Caption8a_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8-3Right")
                        {
                            field("Field 8a_3_1"; Rec."Field 8a_3_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_3_1"));
                                end;
                            }
                            field("Field 8a_3_2"; Rec."Field 8a_3_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_3_2"));
                                end;
                            }
                            field("Field 8a_3_3"; Rec."Field 8a_3_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_3_3"));
                                end;
                            }
                            field("Field 8a_3_4"; Rec."Field 8a_3_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_3_4"));
                                end;
                            }
                        }
                    }
                    grid("Grid8-4")
                    {
                        field(Caption8a_4; Caption8a_4Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8-4Right")
                        {
                            field("Field 8a_4_1"; Rec."Field 8a_4_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_4_1"));
                                end;
                            }
                            field("Field 8a_4_2"; Rec."Field 8a_4_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_4_2"));
                                end;
                            }
                            field("Field 8a_4_3"; Rec."Field 8a_4_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_4_3"));
                                end;
                            }
                            field("Field 8a_4_4"; Rec."Field 8a_4_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_4_4"));
                                end;
                            }
                        }
                    }
                    grid("Grid8-5")
                    {
                        field(Caption8a_5; Caption8a_5Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8-5Right")
                        {
                            field("Field 8a_5_1"; Rec."Field 8a_5_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_5_1"));
                                end;
                            }
                            field("Field 8a_5_2"; Rec."Field 8a_5_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_5_2"));
                                end;
                            }
                            field("Field 8a_5_3"; Rec."Field 8a_5_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_5_3"));
                                end;
                            }
                            field("Field 8a_5_4"; Rec."Field 8a_5_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_5_4"));
                                end;
                            }
                        }
                    }
                    grid("Grid8-6")
                    {
                        field(Caption8a_6; Caption8a_6Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8-6Right")
                        {
                            field("Field 8a_6_1"; Rec."Field 8a_6_1")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(DummyCaption8a_6_2Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 8a_6_3"; Rec."Field 8a_6_3")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(DummyCaption8a_6_4Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid8-7")
                    {
                        field(Caption8a_7; Caption8a_7Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8-7Right")
                        {
                            field("Field 8a_7_1"; Rec."Field 8a_7_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_7_1"));
                                end;
                            }
                            field("Field 8a_7_2"; Rec."Field 8a_7_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_7_2"));
                                end;
                            }
                            field("Field 8a_7_3"; Rec."Field 8a_7_3")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_7_3"));
                                end;
                            }
                            field("Field 8a_7_4"; Rec."Field 8a_7_4")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8a_7_4"));
                                end;
                            }
                        }
                    }
                    grid("Grid8-8")
                    {
                        field(Caption8a_8; Caption8a_8Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8-8Right")
                        {
                            field(DummyCaption8a_8_1Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 8a_8_2"; Rec."Field 8a_8_2")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(DummyCaption8a_8_2Lbl; DummyCaptionLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 8a_8_4"; Rec."Field 8a_8_4")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                }
            }
            group(Group8b)
            {
                Caption = 'EV 8b';
                group("Group8b-Inside")
                {
                    ShowCaption = false;
                    grid("HeaderGrid8b")
                    {
                        ShowCaption = false;
                        field(Caption8b_HeadingLbl; Caption8b_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field(BaseCaption8bLbl; BaseCaptionLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("AboveHeaderGrid8b")
                    {
                        ShowCaption = false;
                        field(DummyCaption8bLbl; DummyCaptionLbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid(AboveHeaderGrid8bRight)
                        {
                            field(GeneralRateCaption8bLbl; GeneralRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(SpecialRateCaption8bLbl; SpecialRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid8b-1")
                    {
                        ShowCaption = false;
                        field(Caption8b_1; Caption8b_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8b-1Right")
                        {
                            field("Field 8b_1_1"; Rec."Field 8b_1_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8b_1_1"));
                                end;
                            }
                            field("Field 8b_1_2"; Rec."Field 8b_1_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8b_1_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid8b-2")
                    {
                        field(Caption8b_2; Caption8b_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8b-2Right")
                        {
                            field("Field 8b_2_1"; Rec."Field 8b_2_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8b_2_1"));
                                end;
                            }
                            field("Field 8b_2_2"; Rec."Field 8b_2_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8b_2_1"));
                                end;
                            }
                        }
                    }
                    grid("Grid8b-3")
                    {
                        field(Caption8b_3; Caption8b_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8b-3Right")
                        {
                            field("Field 8b_3_1"; Rec."Field 8b_3_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8b_3_1"));
                                end;
                            }
                            field("Field 8b_3_2"; Rec."Field 8b_3_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8b_3_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid8b-4")
                    {
                        field(Caption8b_4; Caption8b_4Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8b-4Right")
                        {
                            field("Field 8b_4_1"; Rec."Field 8b_4_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8b_4_1"));
                                end;
                            }
                            field("Field 8b_4_2"; Rec."Field 8b_4_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8b_4_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid8b-5")
                    {
                        field(Caption8b_5; Caption8b_5Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8b-5Right")
                        {
                            field("Field 8b_5_1"; Rec."Field 8b_5_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8b_5_1"));
                                end;
                            }
                            field("Field 8b_5_2"; Rec."Field 8b_5_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8b_5_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid8b-6")
                    {
                        field(Caption8b_6; Caption8b_6Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8b-6Right")
                        {
                            field("Field 8b_6_1"; Rec."Field 8b_6_1")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 8b_6_2"; Rec."Field 8b_6_2")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid8b-7")
                    {
                        field(Caption8b_7; Caption8b_7Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8b-7Right")
                        {
                            field("Field 8b_7_1"; Rec."Field 8b_7_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8b_7_1"));
                                end;
                            }
                            field("Field 8b_7_2"; Rec."Field 8b_7_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8b_7_2"));
                                end;
                            }

                        }
                    }
                }
            }
            group(Group8v)
            {
                Caption = 'EV 8v';
                group("Group8v-Inside")
                {
                    ShowCaption = false;
                    grid("HeaderGrid8v")
                    {
                        ShowCaption = false;
                        field(Caption8v_HeadingLbl; Caption8v_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field(ValueCaption8vLbl; ValueCaptionLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid8v-1")
                    {
                        ShowCaption = false;
                        field(Caption8v_1; Caption8v_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8v_1"; Rec."Field 8v_1")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 8v_1"));
                            end;
                        }
                    }
                    grid("Grid8v-2")
                    {
                        field(Caption8v_2; Caption8v_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8v_2"; Rec."Field 8v_2")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 8v_2"));
                            end;
                        }
                    }
                    grid("Grid8v-3")
                    {
                        field(Caption8v_3; Caption8v_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8v_3"; Rec."Field 8v_3")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 8v_3"));
                            end;
                        }
                    }
                    grid("Grid8v-4")
                    {
                        field(Caption8v_4; Caption8v_4Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8v_4"; Rec."Field 8v_4")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                }
            }
            group(Group8g)
            {
                Caption = 'EV 8g';
                group("Group8g-Inside")
                {
                    ShowCaption = false;
                    grid("HeaderGrid8g")
                    {
                        ShowCaption = false;
                        field(Caption8g_HeadingLbl; Caption8g_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field(BaseCaption8gLbl; BaseCaptionLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("AboveHeaderGrid8g")
                    {
                        ShowCaption = false;
                        field(DummyCaption8gLbl; DummyCaptionLbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid(AboveHeaderGrid8gRight)
                        {
                            field(GeneralRateCaption8gLbl; GeneralRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field(SpecialRateCaption8gLbl; SpecialRateCaptionLbl)
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid8g-1")
                    {
                        ShowCaption = false;
                        field(Caption8g_1; Caption8g_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8g-1Right")
                        {
                            field("Field 8g_1_1"; Rec."Field 8g_1_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8g_1_1"));
                                end;
                            }
                            field("Field 8g_1_2"; Rec."Field 8g_1_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8g_1_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid8g-2")
                    {
                        field(Caption8g_2; Caption8g_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8g-2Right")
                        {
                            field("Field 8g_2_1"; Rec."Field 8g_2_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8g_2_1"));
                                end;
                            }
                            field("Field 8g_2_2"; Rec."Field 8g_2_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8g_2_1"));
                                end;
                            }
                        }
                    }
                    grid("Grid8g-3")
                    {
                        field(Caption8g_3; Caption8g_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8g-3Right")
                        {
                            field("Field 8g_3_1"; Rec."Field 8g_3_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8g_3_1"));
                                end;
                            }
                            field("Field 8g_3_2"; Rec."Field 8g_3_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8g_3_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid8g-4")
                    {
                        field(Caption8g_4; Caption8g_4Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8g-4Right")
                        {
                            field("Field 8g_4_1"; Rec."Field 8g_4_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8g_4_1"));
                                end;
                            }
                            field("Field 8g_4_2"; Rec."Field 8g_4_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8g_4_2"));
                                end;
                            }
                        }
                    }
                    grid("Grid8g-5")
                    {
                        field(Caption8g_5; Caption8g_5Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8g-5Right")
                        {
                            field("Field 8g_5_1"; Rec."Field 8g_5_1")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                            field("Field 8g_5_2"; Rec."Field 8g_5_2")
                            {
                                ShowCaption = false;
                                Style = Strong;
                                ApplicationArea = NPRRSLocal;
                            }
                        }
                    }
                    grid("Grid8g-6")
                    {
                        field(Caption8g_6; Caption8g_6Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        grid("Grid8g-6Right")
                        {
                            field("Field 8g_6_1"; Rec."Field 8g_6_1")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8g_6_1"));
                                end;
                            }
                            field("Field 8g_6_2"; Rec."Field 8g_6_2")
                            {
                                ShowCaption = false;
                                ApplicationArea = NPRRSLocal;
                                trigger OnAssistEdit()
                                begin
                                    Rec.LookUpEntry(Rec.FieldNo("Field 8g_6_2"));
                                end;
                            }
                        }
                    }
                }
            }
            group(Group8d)
            {
                Caption = 'EV 8d';
                group("Group8d-Inside")
                {
                    ShowCaption = false;
                    grid("HeaderGrid8d")
                    {
                        ShowCaption = false;
                        field(Caption8d_HeadingLbl; Caption8d_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field(ValueCaption8dLbl; ValueCaptionLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid8d-1")
                    {
                        ShowCaption = false;
                        field(Caption8d_1; Caption8d_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8d_1"; Rec."Field 8d_1")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 8d_1"));
                            end;
                        }
                    }
                    grid("Grid8d-2")
                    {
                        field(Caption8d_2; Caption8d_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8d_2"; Rec."Field 8d_2")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 8d_2"));
                            end;
                        }
                    }
                    grid("Grid8d-3")
                    {
                        field(Caption8d_3; Caption8d_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8d_3"; Rec."Field 8d_3")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 8d_3"));
                            end;
                        }
                    }
                    grid("Grid8dj")
                    {
                        field(Caption8dj; Caption8djLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8dj"; Rec."Field 8dj")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                }
            }
            group(Group8e)
            {
                Caption = 'EV 8e';
                group("Group8e-Inside")
                {
                    ShowCaption = false;
                    grid("HeaderGrid8e")
                    {
                        ShowCaption = false;
                        field(Caption8e_HeadingLbl; Caption8e_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field(ValueCaption8eLbl; Value2CaptionLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid8e-1")
                    {
                        ShowCaption = false;
                        field(Caption8e_1; Caption8e_1Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8e_1"; Rec."Field 8e_1")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 8e_1"));
                            end;
                        }
                    }
                    grid("Grid8e-2")
                    {
                        field(Caption8e_2; Caption8e_2Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8e_2"; Rec."Field 8e_2")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 8e_2"));
                            end;
                        }
                    }
                    grid("Grid8e-3")
                    {
                        field(Caption8e_3; Caption8e_3Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8e_3"; Rec."Field 8e_3")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 8e_3"));
                            end;
                        }
                    }
                    grid("Grid8e-4")
                    {
                        field(Caption8e_4; Caption8e_4Lbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8e_4"; Rec."Field 8e_4")
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 8e_4"));
                            end;
                        }
                    }
                    grid("Grid8e-5")
                    {
                        field(Caption8e_5; Caption8e_5Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8e_5"; Rec."Field 8e_5")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid8e-6")
                    {
                        field(Caption8e_6; Caption8e_6Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 8e_6"; Rec."Field 8e_6")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                }
            }
            group(Group9)
            {
                Caption = 'EV 9';
                group("Group9-Inside")
                {
                    ShowCaption = false;
                    grid("HeaderGrid9")
                    {
                        ShowCaption = false;
                        field(Caption9_HeadingLbl; Caption9_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 9"; Rec."Field 9")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("HeaderGrid9Separator")
                    {
                        ShowCaption = false;
                        field(DummyCaption9_1_1Lbl; DummyCaptionLbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                        field(DummyCaption9_1_2Lbl; DummyCaptionLbl)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("HeaderGrid9a")
                    {
                        ShowCaption = false;
                        field(Caption9a_HeadingLbl; Caption9a_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field(ValueCaption9aLbl; Value2CaptionLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid9-1")
                    {
                        ShowCaption = false;
                        field(Caption9a_1; Caption9a_1Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 9a_1"; Rec."Field 9a_1")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid9-2")
                    {
                        field(Caption9a_2; Caption9a_2Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 9a_2"; Rec."Field 9a_2")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid9-3")
                    {
                        field(Caption9a_3; Caption9a_3Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 9a_3"; Rec."Field 9a_3")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid9-4")
                    {
                        field(Caption9a_4; Caption9a_4Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 9a_4"; Rec."Field 9a_4")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                }
            }
            group(Group10)
            {
                Caption = 'EV 10';
                group("Group10-Inside")
                {
                    ShowCaption = false;
                    grid("HeaderGrid10")
                    {
                        ShowCaption = false;
                        field(Caption10_HeadingLbl; Caption10_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 10"; Rec."Field 10")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                }
            }

            group(Group11)
            {
                Caption = 'EV 11';
                group("Group11-Inside")
                {
                    ShowCaption = false;
                    grid("HeaderGrid11")
                    {
                        ShowCaption = false;
                        field(Caption11_HeadingLbl; Caption11_HeadingLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field(ValueCaption11Lbl; Value2CaptionLbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                    }
                    grid("Grid11-1")
                    {
                        ShowCaption = false;
                        field(Caption11_1; Caption11_1Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 11_1"; Rec."Field 11_1")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 11_1"));
                            end;
                        }
                    }
                    grid("Grid11-2")
                    {
                        field(Caption11_2; Caption11_2Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 11_2"; Rec."Field 11_2")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 11_2"));
                            end;
                        }
                    }
                    grid("Grid11-3")
                    {
                        field(Caption11_3; Caption11_3Lbl)
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                        }
                        field("Field 11_3"; Rec."Field 11_3")
                        {
                            ShowCaption = false;
                            Style = Strong;
                            ApplicationArea = NPRRSLocal;
                            trigger OnAssistEdit()
                            begin
                                Rec.LookUpEntry(Rec.FieldNo("Field 11_3"));
                            end;
                        }
                    }
                }
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action(POPDV)
            {
                Caption = 'POPDV';
                ToolTip = 'Executed POPDV Report';
                Promoted = true;
                PromotedCategory = Report;
                PromotedOnly = true;
                PromotedIsBig = true;
                Image = PrintVAT;
                ApplicationArea = NPRRSLocal;

                trigger OnAction()
                var
                    POPDV: Report "NPR POPDV";
                begin
                    POPDV.SetDate(StartDate, EndDate);
                    POPDV.SetRecord(Rec);
                    POPDV.RunModal();
                end;
            }

            action(BookOfIncomingInvoices)
            {
                Caption = 'Book of Incoming Invoices';
                ToolTip = 'Execute Book of Incoming Invoices Report';
                Promoted = true;
                PromotedCategory = Report;
                PromotedOnly = true;
                PromotedIsBig = true;
                Image = PrintVAT;
                ApplicationArea = NPRRSLocal;

                trigger OnAction()
                var
                    BookofIncomingInvoices: Report "NPR Book Of Incoming Invoices";
                begin
                    BookofIncomingInvoices.SetDates(StartDate, EndDate);
                    BookofIncomingInvoices.RunModal();
                end;
            }

            action(BookOfOutgoingInvoices)
            {
                Caption = 'Book of Outgoing Invoices';
                ToolTip = 'Execute Book of Outgoing Invoices Report';
                Promoted = true;
                PromotedCategory = Report;
                PromotedOnly = true;
                PromotedIsBig = true;
                Image = PrintVAT;
                ApplicationArea = NPRRSLocal;

                trigger OnAction()
                var
                    BookofOutgoingInvoices: Report "NPR Book Of Outgoing Invoices";
                begin
                    BookofOutgoingInvoices.SetDates(StartDate, EndDate);
                    BookofOutgoingInvoices.RunModal();
                end;
            }

            group(XML)
            {
                Caption = 'XML';
                action(ShowXML)
                {
                    Caption = 'Show XML';
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    Image = XMLFile;
                    ToolTip = 'Executes the Show XML action.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnAction()
                    var
                        Result: Text;
                    begin
                        if not ValidateAndGetXML(Result) then
                            exit;

                        Message(Result);
                    end;
                }
                action(ExportXML)
                {
                    Caption = 'Export XML';
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    Image = ExportElectronicDocument;
                    ToolTip = 'Executes the Export XML action.';
                    ApplicationArea = NPRRSLocal;
                    trigger OnAction()
                    var
                        Result: Text;
                    begin
                        if not ValidateAndGetXML(Result) then
                            exit;


                        RSLocalXMLMgt.ExportXml(Result);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        OpenDateDialog();
        Rec.Init();
        Rec.SetDates(StartDate, EndDate);
        Rec.FillData();
        Rec.SumFields();
        Rec.Insert();
    end;

    local procedure OpenDateDialog()
    var
        DateDialog: Page "NPR Date Dialog";
    begin
        DateDialog.LookupMode(true);
        if DateDialog.RunModal() <> Action::LookupOK then
            exit;
        StartDate := DateDialog.GetStartDate();
        EndDate := DateDialog.GetEndDate();
    end;

    local procedure OpenVATRefundReqDialog(): Boolean
    var
        VATRefundRequiredQst: Label 'Is VAT refund required?';
    begin
        if not ConfirmManagement.GetResponseOrDefault(VATRefundRequiredQst, true) then
            exit;
        exit(true);
    end;

    local procedure ValidateAndGetXML(var Result: Text): Boolean
    var
        TempVATEVEntry: Record "NPR VAT EV Entry" temporary;
        IsVATRefundRequired: Boolean;
    begin
        if (StartDate = 0D) or (EndDate = 0D) then begin
            if not ConfirmManagement.GetResponseOrDefault(DatesInputQst, true) then
                exit
            else begin
                CurrPage.Close();
                Page.Run(Page::"NPR RS POPDV Records");
                exit;
            end;
        end;

        TempVATEVEntry.Copy(Rec, true);

        IsVATRefundRequired := OpenVATRefundReqDialog();

        Result := RSLocalXMLMgt.CreateEPPPDVFormXML(TempVATEVEntry, StartDate, EndDate, IsVATRefundRequired);

        if not RSLocalXMLMgt.ValidateXML(Result) then
            exit;

        exit(true);
    end;

    var
        DummyCaptionLbl: Label '', Locked = true;
        ConfirmManagement: Codeunit "Confirm Management";
        RSLocalXMLMgt: Codeunit "NPR RS Local. XML Mgt.";
        PageCaptionTxt: Label 'VAT EV Entries';
        DatesInputQst: Label 'Both date fields are required. Do you want to enter them?';
        GeneralRateCaptionLbl: Label 'Opšta stopa', Locked = true;
        SpecialRateCaptionLbl: Label 'Posebna stopa', Locked = true;
        DetermingBaseCaptionLbl: Label 'Utvrđivanje osnovice', Locked = true;
        BaseCaptionLbl: Label 'Osnovica', Locked = true;
        AmountCaptionLbl: Label 'PDV', Locked = true;
        Value2CaptionLbl: Label 'Iznos', Locked = true;
        ValueCaptionLbl: Label 'Naknada/vrednost', Locked = true;
        ValueOfCaptionLbl: Label 'Vrednost dobara i usluga', Locked = true;
        Caption1_HeadingLbl: Label 'PROMET DOBARA I USLUGA ZA KOJI JE PROPISANO PORESKO OSLOBOĐENJE SA PRAVOM NA ODBITAK PRETHODNOG POREZA', Locked = true;
        Caption1_1Lbl: Label '1.1 Promet dobara koji se otpremaju u inostranstvo, uključujući i povećanje, odnosno smanjenje naknade za taj promet', Locked = true;
        Caption1_2Lbl: Label '1.2 Promet dobara koji se otpremaju na teritoriju Autonomne pokrajine Kosovo i Metohija, uključujući i povećanje, odnosno smanjenje za taj promet', Locked = true;
        Caption1_3Lbl: Label '1.3 Promet dobara koji se unose u slobodnu zonu i promet dobara i usluga u slobodnoj zoni, uključujući i povećanje, odnosno smanjenje za taj promet', Locked = true;
        Caption1_4Lbl: Label '1.4 Promet dobara i usluga osim iz tač. 1.1 do 1.3, uključujući i povećanje odnosno smanjenje naknade za taj promet', Locked = true;
        Caption1_5Lbl: Label '1.5 Ukupan promet (1.1+1.2+1.3+1.4)', Locked = true;
        Caption1_6Lbl: Label '1.6 Promet dobara i usluga bez naknade', Locked = true;
        Caption1_7Lbl: Label '1.7 Naknada ili deo naknade naplaćen pre izvršenog prometa (avans)', Locked = true;
        Caption2_HeadingLbl: Label 'PROMET DOBARA I USLUGA ZA KOJI JE PROPISANO PORESKO OSLOBOĐENJE BEZ PRAVA NA ODBITAK PRETHODNOG POREZA', Locked = true;
        Caption2_1Lbl: Label '2.1 Promet novca i kapitala, uključujući i povećanje, odnosno smanjenje nakande za taj promet', Locked = true;
        Caption2_2Lbl: Label '2.2 Promet zemljišta i davanje u zakup zemljišta, uključujući i povećanje, odnosno smanjenje naknade za taj promet', Locked = true;
        Caption2_3Lbl: Label '2.3 Promet objekata, uključujući i povećanje odnosno smanjenje naknade za taj promet', Locked = true;
        Caption2_4Lbl: Label '2.4 Promet dobara i usluga, osim iz tač. 2.1 do 2.3 uključujći i povećanje, odnosno smanjenje naknade za taj promet', Locked = true;
        Caption2_5Lbl: Label '2.5 Ukupan promet (2.1+2.2+2.3+2.4)', Locked = true;
        Caption2_6Lbl: Label '2.6 Promet dobara i usluga bez naknade', Locked = true;
        Caption2_7Lbl: Label '2.7 Naknada ili deo naknade naplaćen pre izvršenog prometa (avans)', Locked = true;
        Caption3_HeadingLbl: Label 'OPOREZIVI PROMET DOBARA I USLUGA KOJI VRŠI OBVEZNIK PDV I OBRAČUNATI PDV', Locked = true;
        Caption3_1Lbl: Label '3.1 Prvi prenos prava raspolaganja na novoizgrađenim građevinskim objektima za koji je poreski dužnik obveznik PDV koji vrši taj promet', Locked = true;
        Caption3_2Lbl: Label '3.2 Promet za koji je poreski dužnik obveznik PDV koji vrši taj promet, osim iz tačke 3.1', Locked = true;
        Caption3_3Lbl: Label '3.3 Prenos prava raspolaganja na građevinskim objektima za koji obveznik PDV koji vrši taj promet nije poreski dužnik', Locked = true;
        Caption3_4Lbl: Label '3.4 Promet za koji obveznik PDV koji vrši taj promet nije poreski dužnik, osim iz tačke 3.3', Locked = true;
        Caption3_5Lbl: Label '3.5 Povećanje osnovice, odnosno PDV', Locked = true;
        Caption3_6Lbl: Label '3.6 Smanjenje osnovice, odnosno PDV', Locked = true;
        Caption3_7Lbl: Label '3.7 Promet dobara i usluga bez naknade', Locked = true;
        Caption3_8Lbl: Label '3.8 Ukupna osnovica i obračunati PDV za promet dobara i usluga (3.1+3.2+3.3+3.4+3.5+3.6+3.7)', Locked = true;
        Caption3_9Lbl: Label '3.9 Naknada ili deo naknade koji je naplaćen pre izvršenog prometa i PDV obračunat po tom osnovu (avans)', Locked = true;
        Caption3_10Lbl: Label '3.10 Ukupno obračunati PDV (3.8+3.9)', Locked = true;
        Caption3a_HeadingLbl: Label 'OBRAČUNATI PDV ZA PROMET DRUGOG LICA', Locked = true;
        Caption3a_1Lbl: Label '3a.1 PDV za prenos prava raspolaganja na građevinskim objektima za koji je poreski dužnik obveznik PDV - primalac dobara', Locked = true;
        Caption3a_2Lbl: Label '3a.2 PDV za promet dobara i usluga koji u Republici vrši strano lice koje nije obveznik PDV, za koji je poreski dužnik obveznik PDV - primalac dobara i usluga', Locked = true;
        Caption3a_3Lbl: Label '3a.3 PDV za promet dobara i usluga za koji je poreski dužnik obveznik PDV – primalac dobara i usluga, osim iz tač. 3a.1 i 3a.2, uključujući i PDV obračunat u skladu sa članom 10. stav 3. Zakona', Locked = true;
        Caption3a_4Lbl: Label '3a.4 Povećanje obračunatog PDV', Locked = true;
        Caption3a_5Lbl: Label '3a.5 Smanjenje obračunatog PDV', Locked = true;
        Caption3a_6Lbl: Label '3a.6 PDV za promet dobara i usluga bez naknade', Locked = true;
        Caption3a_7Lbl: Label '3a.7 Ukupno obračunati PDV za promet dobara i usluga (3a.1+3a.2+3a.3+3a.4+3a.5+3a.6)', Locked = true;
        Caption3a_8Lbl: Label '3a.8 PDV po osnovu naknade ili dela naknade koji je plaćen pre izvršenog prometa (avans)', Locked = true;
        Caption3a_9Lbl: Label '3a.9 Ukupno obračunati PDV (3a.7+3a.8)', Locked = true;
        Caption4_HeadingLbl: Label 'POSEBNI POSTUPCI OPOREZIVANJA', Locked = true;
        Caption4_1_HeadingLbl: Label '4.1 Turističke agencije', Locked = true;
        Caption4_1_1Lbl: Label '4.1.1 Naknada koju plaćaju putnici, uključujući i povećanje, odnosno smanjenje te naknade', Locked = true;
        Caption4_1_2Lbl: Label '4.1.2 Stvarni troškovi za prethodne turističke usluge, uključujući i povećanje,odnosno smanjenje tih troškova', Locked = true;
        Caption4_1_3Lbl: Label '4.1.3 Razlika', Locked = true;
        Caption4_1_4Lbl: Label '4.1.4 Obračunati PDV', Locked = true;
        Caption4_2_HeadingLbl: Label '4.2  Polovna dobra, umetnička dela, kolekcionarska dobra i antikviteti', Locked = true;
        Caption4_2_1Lbl: Label '4.2.1 Prodajna cena dobara, uključujući i povećanje, odnosno smanjenje te cene', Locked = true;
        Caption4_2_2Lbl: Label '4.2.2 Nabavna cena dobara, uključujući i povećanje, odnosno smanjenje te cene', Locked = true;
        Caption4_2_3Lbl: Label '4.2.3 Razlika', Locked = true;
        Caption4_2_4Lbl: Label '4.2.4 Obračunati PDV', Locked = true;
        Caption5_HeadingLbl: Label 'UKUPAN PROMET DOBARA I USLUGA I UKUPNO OBRAČUNATI PDV', Locked = true;
        Caption5_1Lbl: Label '5.1 Ukupan oporezivi promet dobara i usluga po opštoj stopi PDV (3.8+4.1.1+4.2.1)', Locked = true;
        Caption5_2Lbl: Label '5.2 Ukupno obračunati PDV po opštoj stopi PDV (3.10+3a.9+4.1.4+4.2.4)', Locked = true;
        Caption5_3Lbl: Label '5.3 Ukupno obračunati PDV po opštoj stopi PDV uvećan za iznos za koji se ne može umanjiti prethodni porez iz tačke 8e.6 (5.2+(8e.6 u apsolutnom iznosu))', Locked = true;
        Caption5_4Lbl: Label '5.4 Ukupan oporezivi promet dobara i usluga po posebnoj stopi PDV (3.8+4.2.1)', Locked = true;
        Caption5_5Lbl: Label '5.5 Ukupno obračunati PDV po posebnoj stopi PDV (3.10+3a.9+4.2.4)', Locked = true;
        Caption5_6Lbl: Label '5.6 Ukupan promet dobara i usluga (1.5+2.5+5.1+5.4)', Locked = true;
        Caption5_7Lbl: Label '5.7 Ukupno obračunati PDV (5.3+5.5)', Locked = true;
        Caption6_HeadingLbl: Label 'UVOZ DOBARA STAVLjENIH U SLOBODAN PROMET U SKLADU SA CARINSKIM PROPISIMA', Locked = true;
        Caption6_1Lbl: Label '6.1 Vrednost dobara za čiji je uvoz propisano poresko oslobođenje, uključujući i povećanje, odnosno smanjenje vrednosti tih dobara', Locked = true;
        Caption6_2Lbl: Label '6.2 Uvoz dobara na koji se plaća PDV', Locked = true;
        Caption6_2_1Lbl: Label '6.2.1 Osnovica za uvoz dobara', Locked = true;
        Caption6_2_2Lbl: Label '6.2.2 Povećanje osnovice za uvoz dobara', Locked = true;
        Caption6_2_3Lbl: Label '6.2.3 Smanjenje osnovice za uvoz dobara', Locked = true;
        Caption6_3Lbl: Label '6.3 Ukupna vrednost, odnosno osnovica za uvoz dobara (6.1+6.2.1+6.2.2+6.2.3)', Locked = true;
        Caption6_4Lbl: Label '6.4 Ukupan PDV plaćen pri uvozu dobara, a koji se može odbiti kao prethodni porez', Locked = true;
        Caption7_HeadingLbl: Label 'NABAVKA DOBARA I USLUGA OD POLjOPRIVREDNIKA', Locked = true;
        Caption7_1Lbl: Label '7.1 Vrednost primljenih dobara i usluga, uključujući i povećanje, odnosno smanjenje te vrednosti', Locked = true;
        Caption7_2Lbl: Label '7.2 Vrednost plaćenih dobara i usluga', Locked = true;
        Caption7_3Lbl: Label '7.3 Plaćena PDV nadoknada', Locked = true;
        Caption7_4Lbl: Label '7.4 Plaćena PDV nadoknada koja se može odbiti kao prethodni porez', Locked = true;
        Caption8_HeadingLbl: Label 'NABAVKA DOBARA I USLUGA, OSIM NABAVKE DOBARA I USLUGA OD POLJOPRIVREDNIKA', Locked = true;
        Caption8a_HeadingLbl: Label '8a Nabavka dobara i usluga u Republici od obveznika PDV - promet za koji je poreski dužnik isporučilac dobara, odnosno pružalac usluga', Locked = true;
        Caption8a_1Lbl: Label '8a.1 Prvi prenos prava raspolaganja na novoizgrađenim građevinskim objektima', Locked = true;
        Caption8a_2Lbl: Label '8a.2 Dobra i usluge, osim dobara iz tačke 8a.1', Locked = true;
        Caption8a_3Lbl: Label '8a.3 Dobra i usluge bez naknade', Locked = true;
        Caption8a_4Lbl: Label '8a.4 Izmena osnovice za nabavljena dobra i usluge i ispravka PDV po osnovu izmene osnovice - povećanje', Locked = true;
        Caption8a_5Lbl: Label '8a.5 Izmena osnovice za nabavljena dobra i usluge i ispravka PDV po osnovu izmene osnovice - smanjenje', Locked = true;
        Caption8a_6Lbl: Label '8a.6 Ukupna osnovica za nabavljena dobra i usluge (8a.1+8a.2+8a.3+8a.4+8a.5)', Locked = true;
        Caption8a_7Lbl: Label '8a.7 Naknada ili deo naknade koji je plaćen pre izvršenog prometa i PDV po tom osnovu (avans)', Locked = true;
        Caption8a_8Lbl: Label '8a.8 Ukupno obračunati PDV od strane obveznika PDV – prethodnog učesnika u prometu (8a.1+8a.2+8a.3+8a.4+8a.5+8a.7)', Locked = true;
        Caption8b_HeadingLbl: Label '8b Nabavka dobara i usluga u Republici od obveznika PDV - promet za koji je poreski dužnik primalac dobara, odnosno usluga', Locked = true;
        Caption8b_1Lbl: Label '8b.1 Prenos prava raspolaganja na građevinskim objektima', Locked = true;
        Caption8b_2Lbl: Label '8b.2 Dobra i usluge, osim dobara iz tačke 8b.1', Locked = true;
        Caption8b_3Lbl: Label '8b.3 Izmena osnovice za nabavljena dobra i usluge - povećanje', Locked = true;
        Caption8b_4Lbl: Label '8b.4 Izmena osnovice za nabavljena dobra i usluge i ispravka PDV po osnovu izmene osnovice - povećanje', Locked = true;
        Caption8b_5Lbl: Label '8b.5 Izmena osnovice za nabavljena dobra i usluge - smanjenje', Locked = true;
        Caption8b_6Lbl: Label '8b.6 Ukupna osnovica za nabavljena dobra i usluge (8b.1+8b.2+8b.3+8b.4+8b.5) ', Locked = true;
        Caption8b_7Lbl: Label '8b.7 Naknada ili deo naknade koji je plaćen pre izvršenog prometa (avans) ', Locked = true;
        Caption8v_HeadingLbl: Label '8v Nabavka dobara i usluga u Republici od obveznika PDV, osim po osnovu prometa za koji postoji obaveza obračunavanja PDV iz tač. 8a i 8b', Locked = true;
        Caption8v_1Lbl: Label '8v.1 Sticanje celokupne, odnosno dela imovine u skladu sa članom 6. stav 1. tačka 1) Zakona i nabavka dobara i usluga u skladu sa članom 6a Zakona, sa ili bez naknade ili kao ulog, uključujući i povećanje, odnosno smanjenje te naknade', Locked = true;
        Caption8v_2Lbl: Label '8v.2 Dobra i usluge uz naknadu, osim iz tačke 8v.1, uključujući i povećanje, odnosno smanjenje te naknade', Locked = true;
        Caption8v_3Lbl: Label '8v.3 Dobra i usluge bez naknade, osim iz tačke 8v.1', Locked = true;
        Caption8v_4Lbl: Label '8v.4 Ukupna naknada, odnosno vrednost nabavljenih dobara i usluga (8v.1+8v.2+8v.3)', Locked = true;
        Caption8g_HeadingLbl: Label '8g Nabavka dobara i usluga u Republici od stranih lica koja nisu obveznici PDV – promet za koji postoji obaveza obračunavanja PDV', Locked = true;
        Caption8g_1Lbl: Label '8g.1 Dobra i usluge', Locked = true;
        Caption8g_2Lbl: Label '8g.2 Dobra i usluge bez naknade', Locked = true;
        Caption8g_3Lbl: Label '8g.3 Izmena osnovice - povećanje', Locked = true;
        Caption8g_4Lbl: Label '8g.4 Izmena osnovice - smanjenje', Locked = true;
        Caption8g_5Lbl: Label '8g.5 Ukupna osnovica za nabavljena dobra i usluge (8g.1+8g.2+8g.3+8g.4)', Locked = true;
        Caption8g_6Lbl: Label '8g.6 Naknada ili deo naknade plaćen pre izvršenog prometa (avans)', Locked = true;
        Caption8d_HeadingLbl: Label '8d Nabavka dobara i usluga, osim iz tač. 8a do 8g', Locked = true;
        Caption8d_1Lbl: Label '8d.1 Dobra i usluge nabavljeni u Republici od stranih lica koja nisu obveznici PDV - promet za koji ne postoji obaveza obračunavanja PDV, kao i povećanje, odnosno smanjenje naknade za ta dobra i usluge, uključujući i nabavku bez naknade', Locked = true;
        Caption8d_2Lbl: Label '8d.2 Dobra i usluge nabavljeni u Republici od lica sa teritorije Republike koja nisu obveznici PDV, kao i povećanje, odnosno smanjenje naknade za ta dobra i usluge, uključujući i nabavku bez naknade', Locked = true;
        Caption8d_3Lbl: Label '8d.3 Dobra i usluge nabavljeni van Republike, kao i povećanje, odnosno smanjenje naknade za ta dobra i usluge, uključujući i nabavku bez naknade', Locked = true;
        Caption8djLbl: Label '8dj Ukupna osnovica, naknada, odnosno vrednost nabavljenih dobara i usluga (8a.6+8b.6+8v.4+8g.5+8d.1+8d.2+8d.3)', Locked = true;
        Caption8e_HeadingLbl: Label '8e PDV ZA PROMET DOBARA I USLUGA KOJI SE MOŽE ODBITI KAO PRETHODNI POREZ I ISPRAVKE ODBITKA PRETHODNOG POREZA', Locked = true;
        Caption8e_1Lbl: Label '8e.1 Ukupno obračunati PDV za promet nabavljenih dobara i usluga za koji je poreski dužnik obveznik PDV - isporučilac dobara, odnosno pružalac usluga, a koji se može odbiti kao prethodni porez (8a.8 umanjen za iznos PDV koji se ne može odbiti kao prethodni porez)', Locked = true;
        Caption8e_2Lbl: Label '8e.2 Ukupno obračunati PDV za promet nabavljenih dobara i usluga za koji je poreski dužnik obveznik PDV - primalac dobara, odnosno usluga, a koji se može odbiti kao prethodni porez (3a.9 umanjen za iznos PDV koji se ne može odbiti kao prethodni porez)', Locked = true;
        Caption8e_3Lbl: Label '8e.3 Ispravka odbitka - povećanje prethodnog poreza, osim po osnovu izmene osnovice za promet dobara i usluga i po osnovu uvoza dobara', Locked = true;
        Caption8e_4Lbl: Label '8e.4 Ispravka odbitka - smanjenje prethodnog poreza, osim po osnovu izmene osnovice za promet dobara i usluga', Locked = true;
        Caption8e_5Lbl: Label '8e.5 Ukupno obračunati PDV za promet dobara i usluga koji se može odbiti kao prethodni porez (8e.1+8e.2+8e.3+8e.4)', Locked = true;
        Caption8e_6Lbl: Label '8e.6 Ukupno obračunati PDV za promet dobara i usluga koji se može odbiti kao prethodni porez uvećan za iznos za koji se ne može umanjiti obračunati PDV (8e.5+(5.2+5.5 u apsolutnom iznosu))', Locked = true;
        Caption9_HeadingLbl: Label '9 UKUPNA VREDNOST NABAVLjENIH DOBARA I USLUGA, UKLjUČUJUĆI I UVOZ DOBARA STAVLjENIH U SLOBODAN PROMET (6.3+7.1+8đ)', Locked = true;
        Caption9a_HeadingLbl: Label '9a PDV KOJI SE U PORESKOJ PRIJAVI ISKAZUJE KAO PRETHODNI POREZ', Locked = true;
        Caption9a_1Lbl: Label '9a.1 PDV plaćen pri uvozu dobara', Locked = true;
        Caption9a_2Lbl: Label '9a.2 PDV nadoknada plaćena poljoprivredniku', Locked = true;
        Caption9a_3Lbl: Label '9a.3 PDV po osnovu nabavki dobara i usluga, osim iz tač. 9a.1 i 9a.2', Locked = true;
        Caption9a_4Lbl: Label '9a.4 Ukupan PDV koji se u poreskoj prijavi iskazuje kao prethodni porez (9a.1+9a.2+9a.3)', Locked = true;
        Caption10_HeadingLbl: Label '10 PORESKA OBAVEZA (5.7-9a.4)', Locked = true;
        Caption11_HeadingLbl: Label '11 PROMET DOBARA I USLUGA IZVRŠEN VAN REPUBLIKE I DRUGI PROMET KOJI NE PODLEŽE PDV', Locked = true;
        Caption11_1Lbl: Label '11.1 Promet dobara i usluga izvršen van Republike, sa ili bez naknade', Locked = true;
        Caption11_2Lbl: Label '11.2 Prenos celokupne, odnosno dela imovine u skladu sa članom 6. stav 1. tačka 1) Zakona i promet dobara i usluga u skladu sa članom 6a Zakona, sa ili bez naknade ili kao ulog', Locked = true;
        Caption11_3Lbl: Label '11.3 Promet dobara i usluga iz člana 6. Zakona, osim iz tačke 11.2', Locked = true;
        StartDate, EndDate : Date;
}

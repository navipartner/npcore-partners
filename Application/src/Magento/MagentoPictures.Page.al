page 6151411 "NPR Magento Pictures"
{
    Caption = 'Magento Pictures';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento Picture";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(Control6150622)
            {
                ShowCaption = false;
                repeater(Group)
                {
                    field(Type; Rec.Type)
                    {

                        ToolTip = 'Specifies the value of the Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Name; Rec.Name)
                    {

                        ToolTip = 'Specifies the value of the Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Count"; Counter)
                    {

                        Caption = 'Count';
                        ToolTip = 'Specifies the value of the Count field';
                        ApplicationArea = NPRRetail;

                        trigger OnDrillDown()
                        begin
                            DrillDownCounter();
                        end;
                    }
                    field("Last Date Modified"; Rec."Last Date Modified")
                    {

                        ToolTip = 'Specifies the value of the Last Date Modified field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Last Time Modified"; Rec."Last Time Modified")
                    {

                        ToolTip = 'Specifies the value of the Last Time Modified field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Size (kb)"; Rec."Size (kb)")
                    {

                        Visible = false;
                        ToolTip = 'Specifies the value of the Size (kb) field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
        area(factboxes)
        {
            part(DragDropAddin; "NPR Magento DragDropPic. Addin")
            {
                Caption = 'DragAndDrop Picture';
                ShowFilter = false;
                SubPageLink = Type = FIELD(Type),
                              Name = FIELD(Name);
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Show Invalid Pictures")
            {
                Caption = 'Show Invalid Pictures';
                Image = TestFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Show Invalid Pictures action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Window: Dialog;
                    Counter: Integer;
                    Total: Integer;
                begin
                    Clear(Rec);
                    Total := Rec.Count();
                    Window.Open(Text000);
                    if Rec.FindSet() then
                        repeat
                            Counter += 1;
                            Window.Update(1, Round((Counter / Total) * 10000, 1));

                            Rec.Mark(not Rec.TryCheckPicture());
                        until Rec.Next() = 0;
                    Window.Close();

                    Rec.MarkedOnly(true);
                    if Rec.FindFirst() then;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        TempMagentoPicture2: Record "NPR Magento Picture" temporary;
    begin
        CountRelations();
        if TempMagentoPicture.Get(Rec.Type, Rec.Name) then begin
            TempMagentoPicture.CalcFields(Picture);
            exit;
        end;
        Clear(TempMagentoPicture2);
        if MiniatureLinePicture then
            Rec.DownloadPicture(TempMagentoPicture2);

        TempMagentoPicture.Init();
        TempMagentoPicture := Rec;
        // TempMagentoPicture.Image := TempMagentoPicture2.Image;
        TempMagentoPicture.Picture := TempMagentoPicture2.Picture;
        TempMagentoPicture.Insert();
    end;

    trigger OnInit()
    begin
        GetMiniatureSetup();
        CurrPage.DragDropAddin.PAGE.SetHidePicture(not MiniatureSinglePicture);
    end;

    var
        MagentoSetup: Record "NPR Magento Setup";
        TempMagentoPicture: Record "NPR Magento Picture" temporary;
        Counter: Integer;
        MiniatureLinePicture: Boolean;
        MiniatureSinglePicture: Boolean;
        Text000: Label 'Checking Pictures: @1@@@@@@@@@@@@@@@';

    procedure CountRelations()
    var
        MagentoPictureLink: Record "NPR Magento Picture Link";
        MagentoItemGroup: Record "NPR Magento Category";
        MagentoBrand: Record "NPR Magento Brand";
        MagentoAttributeLabel: Record "NPR Magento Attr. Label";
    begin
        Counter := 0;
        case Rec.Type of
            Rec.Type::Item:
                begin
                    MagentoPictureLink.SetRange("Picture Name", Rec.Name);
                    Counter := MagentoPictureLink.Count();
                end;
            Rec.Type::"Item Group":
                begin
                    MagentoItemGroup.SetRange(Picture, Rec.Name);
                    Counter := MagentoItemGroup.Count();
                end;
            Rec.Type::Brand:
                begin
                    MagentoBrand.SetRange(Picture, Rec.Name);
                    Counter := MagentoBrand.Count();
                end;
            Rec.Type::Customer:
                begin
                    MagentoAttributeLabel.SetRange(Image, Rec.Name);
                    Counter := MagentoAttributeLabel.Count();
                end;
        end;
    end;

    procedure DrillDownCounter()
    var
        Item: Record Item;
        MagentoPictureLink: Record "NPR Magento Picture Link";
        MagentoItemGroup: Record "NPR Magento Category";
        MagentoBrand: Record "NPR Magento Brand";
        TempItem: Record Item temporary;
    begin
        if Counter <> 0 then begin
            case Rec.Type of
                Rec.Type::Item:
                    begin
                        Clear(MagentoPictureLink);
                        MagentoPictureLink.SetRange("Picture Name", Rec.Name);
                        if MagentoPictureLink.FindSet() then
                            repeat
                                if not TempItem.Get(MagentoPictureLink."Item No.") then begin
                                    if Item.Get(MagentoPictureLink."Item No.") then begin
                                        TempItem.Init();
                                        TempItem := Item;
                                        TempItem.Insert();
                                    end else begin
                                        TempItem.Init();
                                        TempItem."No." := MagentoPictureLink."Item No.";
                                        TempItem.Insert();
                                    end;
                                end;
                            until MagentoPictureLink.Next() = 0;
                        PAGE.Run(PAGE::"Item List", TempItem);
                    end;
                Rec.Type::"Item Group":
                    begin
                        Clear(MagentoItemGroup);
                        MagentoItemGroup.SetRange(Picture, Rec.Name);
                        PAGE.Run(PAGE::"NPR Magento Category List", MagentoItemGroup);
                    end;
                Rec.Type::Brand:
                    begin
                        Clear(MagentoBrand);
                        MagentoBrand.SetRange(Picture, Rec.Name);
                        PAGE.Run(PAGE::"NPR Magento Brands", MagentoBrand);
                    end;
            end;
        end;
    end;

    local procedure GetMiniatureSetup()
    begin
        if not MagentoSetup.Get() then
            exit;
        MiniatureSinglePicture := MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::SinglePicutre, MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"];
        MiniatureLinePicture := MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::LinePicture, MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"];
    end;
}
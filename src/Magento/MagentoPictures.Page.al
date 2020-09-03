page 6151411 "NPR Magento Pictures"
{
    // MAG1.01/HSK /20150129 CASE 205438 Added functions:
    //                                   - CountRelations() - Counts the number of picture links.
    //                                   - DrillDownCounter() - Page.RUN of picture links data.
    // MAG1.04/MHA /20150209  CASE 199932 Updated PictureViewer Addin
    // MAG1.09/MHA /20150316  CASE 206395 Updated Layout with Repeater-Picture-Blob
    // MAG1.12/MHA /20150403  CASE 210709 Removed Picture field due to performance
    // MAG1.14/MHA /20150508  CASE 211881 Updated PictureViewer Addin to JavaScript version
    // MAG1.21/MHA /20151118  CASE 223835 Type deleted from Picture Link and Added Miniature
    // MAG1.22/MHA /20160421  CASE 230240 Changed "Size (kb)" to Non Visible
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG10.00.2.00/MHA/20161118  CASE 258544 Changed Miniature to use Picture instead of TempItem.Picture
    // MAG2.22/MHA /20190716  CASE 361234 Added Action "Check Invalid Pictures"

    Caption = 'Magento Pictures';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento Picture";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Control6150622)
            {
                ShowCaption = false;
                repeater(Group)
                {
                    field(MiniatureLine; TempMagentoPicture.Picture)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Miniature';
                        Editable = false;
                        Visible = MiniatureLinePicture;
                    }
                    field(Type; Type)
                    {
                        ApplicationArea = All;
                    }
                    field(Name; Name)
                    {
                        ApplicationArea = All;
                    }
                    field("Count"; Counter)
                    {
                        ApplicationArea = All;
                        Caption = 'Count';

                        trigger OnDrillDown()
                        begin
                            DrillDownCounter();
                        end;
                    }
                    field("Last Date Modified"; "Last Date Modified")
                    {
                        ApplicationArea = All;
                    }
                    field("Last Time Modified"; "Last Time Modified")
                    {
                        ApplicationArea = All;
                    }
                    field("Size (kb)"; "Size (kb)")
                    {
                        ApplicationArea = All;
                        Visible = false;
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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MagentoPicture: Record "NPR Magento Picture";
                    Window: Dialog;
                    Counter: Integer;
                    Total: Integer;
                begin
                    //-MAG2.22 [361234]
                    Clear(Rec);
                    Total := Count;
                    Window.Open(Text000);
                    if FindSet then
                        repeat
                            Counter += 1;
                            Window.Update(1, Round((Counter / Total) * 10000, 1));

                            Mark(not TryCheckPicture());
                        until Next = 0;
                    Window.Close;

                    MarkedOnly(true);
                    if FindFirst then;
                    //+MAG2.22 [361234]
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        TempMagentoPicture2: Record "NPR Magento Picture" temporary;
    begin
        CountRelations();
        //-MAG10.00.2.00 [258544]
        if TempMagentoPicture.Get(Type, Name) then begin
            TempMagentoPicture.CalcFields(Picture);
            exit;
        end;
        Clear(TempMagentoPicture2);
        if MiniatureLinePicture then
            DownloadPicture(TempMagentoPicture2);

        TempMagentoPicture.Init;
        TempMagentoPicture := Rec;
        TempMagentoPicture.Picture := TempMagentoPicture2.Picture;
        TempMagentoPicture.Insert;
        //+MAG10.00.2.00 [258544]
    end;

    trigger OnInit()
    begin
        //-MAG1.21
        GetMiniatureSetup();
        CurrPage.DragDropAddin.PAGE.SetHidePicture(not MiniatureSinglePicture);
        //+MAG1.21
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
        case Type of
            Type::Item:
                begin
                    MagentoPictureLink.SetRange("Picture Name", Name);
                    Counter := MagentoPictureLink.Count;
                end;
            Type::"Item Group":
                begin
                    MagentoItemGroup.SetRange(Picture, Name);
                    Counter := MagentoItemGroup.Count;
                end;
            Type::Brand:
                begin
                    MagentoBrand.SetRange(Picture, Name);
                    Counter := MagentoBrand.Count;
                end;
            Type::Customer:
                begin
                    MagentoAttributeLabel.SetRange(Image, Name);
                    Counter := MagentoAttributeLabel.Count;
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
        TempItem2: Record Item temporary;
    begin
        if Counter <> 0 then begin
            case Type of
                Type::Item:
                    begin
                        Clear(MagentoPictureLink);
                        MagentoPictureLink.SetRange("Picture Name", Name);
                        if MagentoPictureLink.FindSet then
                            repeat
                                if not TempItem.Get(MagentoPictureLink."Item No.") then begin
                                    //-MAG2.22 [361234]
                                    if Item.Get(MagentoPictureLink."Item No.") then begin
                                        TempItem.Init;
                                        TempItem := Item;
                                        TempItem.Insert;
                                    end else begin
                                        TempItem.Init;
                                        TempItem."No." := MagentoPictureLink."Item No.";
                                        TempItem.Insert;
                                    end;
                                    //+MAG2.22 [361234]
                                end;
                            until MagentoPictureLink.Next = 0;
                        PAGE.Run(PAGE::"NPR Retail Item List", TempItem);
                    end;
                Type::"Item Group":
                    begin
                        Clear(MagentoItemGroup);
                        MagentoItemGroup.SetRange(Picture, Name);
                        PAGE.Run(PAGE::"NPR Magento Category List", MagentoItemGroup);
                    end;
                Type::Brand:
                    begin
                        Clear(MagentoBrand);
                        MagentoBrand.SetRange(Picture, Name);
                        PAGE.Run(PAGE::"NPR Magento Brands", MagentoBrand);
                    end;
            end;
        end;
    end;

    local procedure "--- Miniature"()
    begin
    end;

    local procedure GetMiniatureSetup()
    begin
        //-MAG1.21
        if not MagentoSetup.Get then
            exit;
        MiniatureSinglePicture := MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::SinglePicutre, MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"];
        MiniatureLinePicture := MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::LinePicture, MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"];
        //+MAG1.21
    end;

    [TryFunction]
    procedure TryCheckPicture()
    var
        WebRequest: DotNet NPRNetWebRequest;
        WebResponse: DotNet NPRNetWebResponse;
    begin
        //-MAG2.22 [361234]
        WebRequest := WebRequest.CreateHttp(GetMagentotUrl());
        WebRequest.Method := 'HEAD';
        WebResponse := WebRequest.GetResponse();
        //+MAG2.22 [361234]
    end;
}


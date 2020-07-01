codeunit 6060082 "MCS Recommendations Handler"
{
    // NPR5.30/BR  /20170228  CASE 252646 Object Created
    // NPR5.34/BR  /20170725  CASE 275206 Check if the number to export is valid


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Refreshing Recommendations for Item #1##########';
        TextInvalidItemNo: Label 'No recommendations can be generated for item no %1. Item numbers can only contain: [A-z], [a-z], [0-9], [_] (Underscore) and [-] (Dash).';

    procedure RefreshRecommendations(MCSRecommendationsModel: Record "MCS Recommendations Model"; ShowDialog: Boolean)
    var
        Item: Record Item;
        TaskDialog: Dialog;
    begin
        if ShowDialog and GuiAllowed then
            TaskDialog.Open(Text001, Item."No.");
        Item.Reset;
        if MCSRecommendationsModel."Item View" <> '' then
            Item.SetView(MCSRecommendationsModel."Item View");
        if Item.FindSet then
            repeat
                if ShowDialog and GuiAllowed then
                    TaskDialog.Update;
                //-NPR5.34 [275206]
                if IsValidMCSNo(Item."No.") then begin
                    //+NPR5.34 [275206]
                    DeleteItemRecommendations(MCSRecommendationsModel, Item);
                    InsertItemRecommendations(Item, MCSRecommendationsModel);
                    Commit;
                    //-NPR5.34 [275206]
                end;
            //+NPR5.34 [275206]
            until Item.Next = 0;
        if ShowDialog and GuiAllowed then
            TaskDialog.Close;
    end;

    local procedure InsertItemRecommendations(Item: Record Item; MCSRecommendationsModel: Record "MCS Recommendations Model")
    var
        MCSRecommendationsLog: Record "MCS Recommendations Log";
        MCSRecommendationsLine: Record "MCS Recommendations Line";
        TempMCSRecommendationsLine: Record "MCS Recommendations Line" temporary;
        MCSRecServiceAPI: Codeunit "MCS Rec. Service API";
    begin
        //-NPR5.34 [275206]
        if not IsValidMCSNo(Item."No.") then
            Error(TextInvalidItemNo, Item."No.");
        //+NPR5.34 [275206]

        InsertRecommendationsLog(MCSRecommendationsLog);
        MCSRecommendationsLog."Model No." := MCSRecommendationsModel.Code;

        TempMCSRecommendationsLine.Init;
        TempMCSRecommendationsLine."Model No." := MCSRecommendationsModel.Code;
        TempMCSRecommendationsLine."Log Entry No." := MCSRecommendationsLog."Entry No.";
        TempMCSRecommendationsLine."Seed Item No." := Item."No.";
        TempMCSRecommendationsLine."Table No." := DATABASE::Item;
        MCSRecServiceAPI.GetRecommendationsLines(TempMCSRecommendationsLine, false);

        if TempMCSRecommendationsLine.FindSet then
            repeat
                MCSRecommendationsLine := TempMCSRecommendationsLine;
                MCSRecommendationsLine."Entry No." := 0;
                MCSRecommendationsLine.Insert(true);
            until TempMCSRecommendationsLine.Next = 0;

        MCSRecommendationsLog.Success := true;
        MCSRecommendationsLog."End Date Time" := CurrentDateTime;
        MCSRecommendationsLog.Modify(true);
    end;

    local procedure DeleteItemRecommendations(MCSRecommendationsModel: Record "MCS Recommendations Model"; Item: Record Item)
    var
        MCSRecommendationsLine: Record "MCS Recommendations Line";
    begin
        MCSRecommendationsLine.Reset;
        MCSRecommendationsLine.SetRange("Model No.", MCSRecommendationsModel.Code);
        MCSRecommendationsLine.SetRange("Table No.", DATABASE::Item);
        MCSRecommendationsLine.SetRange("Seed Item No.", Item."No.");
        MCSRecommendationsLine.DeleteAll(true);
    end;

    procedure InsertPOSSaleRecommendations(MCSRecommendationsModel: Record "MCS Recommendations Model"; SalePOS: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        DeletePOSSaleRecommendations(MCSRecommendationsModel, SalePOS);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        if SaleLinePOS.FindSet then
            repeat
                InsertPOSSaleLineRecommendations(MCSRecommendationsModel, SalePOS, SaleLinePOS);
            until SaleLinePOS.Next = 0;
    end;

    procedure InsertPOSSaleLineRecommendations(MCSRecommendationsModel: Record "MCS Recommendations Model"; SalePOS: Record "Sale POS"; SaleLinePOS: Record "Sale Line POS")
    var
        MCSRecommendationsLine: Record "MCS Recommendations Line";
        MCSRecommendationsLog: Record "MCS Recommendations Log";
        TempMCSRecommendationsLine: Record "MCS Recommendations Line" temporary;
        MCSRecServiceAPI: Codeunit "MCS Rec. Service API";
    begin
        if not SaleLinePOSIsInModelFilter(SaleLinePOS, MCSRecommendationsModel) then
            exit;
        //-NPR5.34 [275206]
        if not IsValidMCSNo(SaleLinePOS."No.") then
            exit;
        //+NPR5.34 [275206]
        InsertRecommendationsLog(MCSRecommendationsLog);
        MCSRecommendationsLog."Model No." := MCSRecommendationsModel.Code;

        TempMCSRecommendationsLine.Init;
        TempMCSRecommendationsLine."Model No." := MCSRecommendationsModel.Code;
        TempMCSRecommendationsLine."Log Entry No." := MCSRecommendationsLog."Entry No.";
        TempMCSRecommendationsLine."Table No." := DATABASE::"Sale Line POS";
        TempMCSRecommendationsLine."Register No." := SaleLinePOS."Register No.";
        TempMCSRecommendationsLine."Document No." := SaleLinePOS."Sales Ticket No.";
        TempMCSRecommendationsLine."Document Line No." := SaleLinePOS."Line No.";
        TempMCSRecommendationsLine."Document Date" := SaleLinePOS.Date;
        TempMCSRecommendationsLine."Seed Item No." := SaleLinePOS."No.";
        TempMCSRecommendationsLine."Customer No." := SalePOS."Customer No.";

        MCSRecServiceAPI.GetRecommendationsLines(TempMCSRecommendationsLine, false);

        if TempMCSRecommendationsLine.FindSet then
            repeat
                MCSRecommendationsLine := TempMCSRecommendationsLine;
                MCSRecommendationsLine."Entry No." := 0;
                MCSRecommendationsLine.Insert(true);
            until TempMCSRecommendationsLine.Next = 0;

        MCSRecommendationsLog.Success := true;
        MCSRecommendationsLog."End Date Time" := CurrentDateTime;
        MCSRecommendationsLog.Modify(true);
    end;

    procedure InsertSalesRecommendations(MCSRecommendationsModel: Record "MCS Recommendations Model"; SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        DeleteSalesRecommendations(MCSRecommendationsModel, SalesHeader);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet then
            repeat
                InsertSalesLineRecommendations(MCSRecommendationsModel, SalesHeader, SalesLine);
            until SalesLine.Next = 0;
    end;

    procedure InsertSalesLineRecommendations(MCSRecommendationsModel: Record "MCS Recommendations Model"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        MCSRecommendationsLine: Record "MCS Recommendations Line";
        MCSRecommendationsLog: Record "MCS Recommendations Log";
        TempMCSRecommendationsLine: Record "MCS Recommendations Line" temporary;
        MCSRecServiceAPI: Codeunit "MCS Rec. Service API";
    begin
        if not SalesLineIsInModelFilter(SalesLine, MCSRecommendationsModel) then
            exit;
        //-NPR5.34 [275206]
        if not IsValidMCSNo(SalesLine."No.") then
            exit;
        //+NPR5.34 [275206]

        InsertRecommendationsLog(MCSRecommendationsLog);
        MCSRecommendationsLog."Model No." := MCSRecommendationsModel.Code;

        TempMCSRecommendationsLine.Init;
        TempMCSRecommendationsLine."Model No." := MCSRecommendationsModel.Code;
        TempMCSRecommendationsLine."Log Entry No." := MCSRecommendationsLog."Entry No.";
        TempMCSRecommendationsLine."Table No." := DATABASE::"Sales Line";
        TempMCSRecommendationsLine."Document Type" := SalesHeader."Document Type";
        TempMCSRecommendationsLine."Document No." := SalesHeader."No.";
        TempMCSRecommendationsLine."Document Line No." := SalesLine."Line No.";
        TempMCSRecommendationsLine."Document Date" := SalesHeader."Document Date";
        TempMCSRecommendationsLine."Seed Item No." := SalesLine."No.";
        TempMCSRecommendationsLine."Customer No." := SalesHeader."Sell-to Customer No.";

        MCSRecServiceAPI.GetRecommendationsLines(TempMCSRecommendationsLine, false);

        if TempMCSRecommendationsLine.FindSet then
            repeat
                MCSRecommendationsLine := TempMCSRecommendationsLine;
                MCSRecommendationsLine."Entry No." := 0;
                MCSRecommendationsLine.Insert(true);
            until TempMCSRecommendationsLine.Next = 0;

        MCSRecommendationsLog.Success := true;
        MCSRecommendationsLog."End Date Time" := CurrentDateTime;
        MCSRecommendationsLog.Modify(true);
    end;

    local procedure DeletePOSSaleRecommendations(MCSRecommendationsModel: Record "MCS Recommendations Model"; SalePOS: Record "Sale POS")
    var
        MCSRecommendationsLine: Record "MCS Recommendations Line";
    begin
        MCSRecommendationsLine.Reset;
        MCSRecommendationsLine.SetRange("Table No.", DATABASE::"Sale Line POS");
        MCSRecommendationsLine.SetRange("Model No.", MCSRecommendationsModel.Code);
        MCSRecommendationsLine.SetRange("Register No.", SalePOS."Register No.");
        MCSRecommendationsLine.SetRange("Document No.", SalePOS."Sales Ticket No.");
        MCSRecommendationsLine.SetRange("Document Date", SalePOS.Date);
        MCSRecommendationsLine.DeleteAll(true);
    end;

    procedure DeletePOSSaleLineRecommendations(MCSRecommendationsModel: Record "MCS Recommendations Model"; SaleLinePOS: Record "Sale Line POS")
    var
        MCSRecommendationsLine: Record "MCS Recommendations Line";
    begin
        MCSRecommendationsLine.Reset;
        MCSRecommendationsLine.SetRange("Table No.", DATABASE::"Sale Line POS");
        MCSRecommendationsLine.SetRange("Model No.", MCSRecommendationsModel.Code);
        MCSRecommendationsLine.SetRange("Register No.", SaleLinePOS."Register No.");
        MCSRecommendationsLine.SetRange("Document No.", SaleLinePOS."Sales Ticket No.");
        MCSRecommendationsLine.SetRange("Document Line No.", SaleLinePOS."Line No.");
        MCSRecommendationsLine.SetRange("Document Date", SaleLinePOS.Date);
        MCSRecommendationsLine.DeleteAll(true);
    end;

    local procedure DeleteSalesRecommendations(MCSRecommendationsModel: Record "MCS Recommendations Model"; SalesHeader: Record "Sales Header")
    var
        MCSRecommendationsLine: Record "MCS Recommendations Line";
    begin
        MCSRecommendationsLine.Reset;
        MCSRecommendationsLine.SetRange("Table No.", DATABASE::"Sales Line");
        MCSRecommendationsLine.SetRange("Model No.", MCSRecommendationsModel.Code);
        MCSRecommendationsLine.SetRange("Document Type", SalesHeader."Document Type");
        MCSRecommendationsLine.SetRange("Document No.", SalesHeader."No.");
        MCSRecommendationsLine.DeleteAll(true);
    end;

    procedure DeleteSalesLineRecommendations(MCSRecommendationsModel: Record "MCS Recommendations Model"; SalesLine: Record "Sales Line")
    var
        MCSRecommendationsLine: Record "MCS Recommendations Line";
    begin
        MCSRecommendationsLine.Reset;
        MCSRecommendationsLine.SetRange("Model No.", MCSRecommendationsModel.Code);
        MCSRecommendationsLine.SetRange("Table No.", DATABASE::"Sales Line");
        MCSRecommendationsLine.SetRange("Document Type", SalesLine."Document Type");
        MCSRecommendationsLine.SetRange("Document No.", SalesLine."Document No.");
        MCSRecommendationsLine.SetRange("Document Line No.", SalesLine."Line No.");
        MCSRecommendationsLine.DeleteAll(true);
    end;

    local procedure InsertRecommendationsLog(var MCSRecommendationsLog: Record "MCS Recommendations Log")
    begin
        MCSRecommendationsLog.Init;
        MCSRecommendationsLog."Entry No." := 0;
        MCSRecommendationsLog.Type := MCSRecommendationsLog.Type::RecommendationRequest;
        MCSRecommendationsLog."Start Date Time" := CurrentDateTime;
        MCSRecommendationsLog.Insert(true);
    end;

    procedure GetRecommendationsLinesFromSalePOS(SalePOS: Record "Sale POS"; var TempMCSRecommendationsLine: Record "MCS Recommendations Line")
    var
        MCSRecommendationsLine: Record "MCS Recommendations Line";
        Item: Record Item;
        SaleLinePOS: Record "Sale Line POS";
    begin
        if (not TempMCSRecommendationsLine.IsTemporary) then
            exit;

        TempMCSRecommendationsLine.DeleteAll;

        MCSRecommendationsLine.Reset;
        MCSRecommendationsLine.SetRange("Table No.", 6014405, 6014406);
        MCSRecommendationsLine.SetRange("Document No.", SalePOS."Sales Ticket No.");
        if MCSRecommendationsLine.FindSet then begin
            //Recommendations for this specific Sale
            repeat
                TempMCSRecommendationsLine := MCSRecommendationsLine;
                TempMCSRecommendationsLine.Insert;
            until MCSRecommendationsLine.Next = 0;
        end else begin
            //General Recommendations for the items in this sale
            MCSRecommendationsLine.SetRange("Table No.", 27);
            MCSRecommendationsLine.SetRange("Document No.");
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.SetRange(Date, SalePOS.Date);
            SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
            if SaleLinePOS.FindSet then
                repeat
                    MCSRecommendationsLine.SetRange("Seed Item No.", SaleLinePOS."No.");
                    if MCSRecommendationsLine.FindSet then
                        repeat
                            if not TempMCSRecommendationsLine.Get(MCSRecommendationsLine."Entry No.") then begin
                                TempMCSRecommendationsLine := MCSRecommendationsLine;
                                TempMCSRecommendationsLine.Insert;
                            end;
                        until MCSRecommendationsLine.Next = 0;
                until SaleLinePOS.Next = 0;
        end;
    end;

    procedure GetRecommendationsLinesFromSales(SalesHeader: Record "Sales Header"; var TempMCSRecommendationsLine: Record "MCS Recommendations Line")
    var
        MCSRecommendationsLine: Record "MCS Recommendations Line";
        Item: Record Item;
        SalesLine: Record "Sales Line";
    begin
        if (not TempMCSRecommendationsLine.IsTemporary) then
            exit;

        TempMCSRecommendationsLine.DeleteAll;

        MCSRecommendationsLine.Reset;
        MCSRecommendationsLine.SetRange("Table No.", 36, 37);
        MCSRecommendationsLine.SetRange("Document Type", SalesHeader."Document Type");
        MCSRecommendationsLine.SetRange("Document No.", SalesHeader."No.");
        if MCSRecommendationsLine.FindSet then begin
            //Recommendations for this specific Sale
            repeat
                TempMCSRecommendationsLine := MCSRecommendationsLine;
                TempMCSRecommendationsLine.Insert;
            until MCSRecommendationsLine.Next = 0;
        end else begin
            //General Recommendations for the items in this sale
            MCSRecommendationsLine.SetRange("Table No.", DATABASE::Item);
            MCSRecommendationsLine.SetRange("Document Type");
            MCSRecommendationsLine.SetRange("Document No.");
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            if SalesLine.FindSet then
                repeat
                    MCSRecommendationsLine.SetRange("Seed Item No.", SalesLine."No.");
                    if MCSRecommendationsLine.FindSet then
                        repeat
                            if not TempMCSRecommendationsLine.Get(MCSRecommendationsLine."Entry No.") then begin
                                TempMCSRecommendationsLine := MCSRecommendationsLine;
                                TempMCSRecommendationsLine.Insert;
                            end;
                        until MCSRecommendationsLine.Next = 0;
                until SalesLine.Next = 0;
        end;
    end;

    procedure GetItemListFromRecommendations(var TempItem: Record Item temporary; var TempMCSRecommendationsLine: Record "MCS Recommendations Line" temporary; NumberOfItemsToReturn: Integer)
    var
        Item: Record Item;
        TempMCSRecommendationsLine2: Record "MCS Recommendations Line" temporary;
    begin
        if (not TempItem.IsTemporary) or (not TempMCSRecommendationsLine.IsTemporary) then
            exit;
        TempMCSRecommendationsLine.Reset;
        TempItem.DeleteAll;
        //First delete any recommendations for Seed Items
        //( Seed items are already in the sale and should not be recommended)
        if TempMCSRecommendationsLine.FindSet then
            repeat
                TempMCSRecommendationsLine2 := TempMCSRecommendationsLine;
                TempMCSRecommendationsLine2.Insert;
            until TempMCSRecommendationsLine.Next = 0;
        if TempMCSRecommendationsLine2.FindSet then
            repeat
                TempMCSRecommendationsLine.SetRange("Item No.", TempMCSRecommendationsLine2."Seed Item No.");
                TempMCSRecommendationsLine.DeleteAll;
            until TempMCSRecommendationsLine2.Next = 0;

        //Insert Unique recommended items according to descending rating
        TempMCSRecommendationsLine.Reset;
        TempMCSRecommendationsLine.SetCurrentKey("Table No.", "Document No.", Rating);
        if TempMCSRecommendationsLine.FindLast then
            repeat
                if not TempItem.Get(TempMCSRecommendationsLine."Item No.") then begin
                    if Item.Get(TempMCSRecommendationsLine."Item No.") then begin
                        TempItem := Item;
                        TempItem.Insert;
                    end;
                end;
            until (TempMCSRecommendationsLine.Next(-1) = 0) or (TempItem.Count = NumberOfItemsToReturn)
    end;

    local procedure SaleLinePOSIsInModelFilter(SaleLinePOS: Record "Sale Line POS"; MCSRecommendationsModel: Record "MCS Recommendations Model"): Boolean
    var
        TempItem: Record Item temporary;
        Item: Record Item;
    begin
        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
            exit(false);
        if not Item.Get(SaleLinePOS."No.") then
            exit(false);
        if MCSRecommendationsModel."Item View" = '' then
            exit(true);
        TempItem := Item;
        TempItem.Insert;
        TempItem.SetView(MCSRecommendationsModel."Item View");
        exit(not TempItem.IsEmpty);
    end;

    local procedure SalesLineIsInModelFilter(SalesLine: Record "Sales Line"; MCSRecommendationsModel: Record "MCS Recommendations Model"): Boolean
    var
        TempItem: Record Item temporary;
        Item: Record Item;
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit(false);
        if not Item.Get(SalesLine."No.") then
            exit(false);
        if MCSRecommendationsModel."Item View" = '' then
            exit(true);
        TempItem := Item;
        TempItem.Insert;
        TempItem.SetView(MCSRecommendationsModel."Item View");
        exit(not TempItem.IsEmpty);
    end;

    procedure IsValidMCSNo(InputText: Text): Boolean
    var
        RegEx: Codeunit DotNet_Regex;
    begin
        //-NPR5.34 [275206]
        exit(RegEx.IsMatch(InputText, '^[a-zA-Z0-9-_]*$'));
        //+NPR5.34 [275206]
    end;
}


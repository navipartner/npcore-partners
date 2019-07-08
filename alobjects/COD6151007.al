codeunit 6151007 "POS Entry Sales Doc. Link Mgt."
{
    // NPR5.50/MMV /20190417 CASE 300557 Created object


    trigger OnRun()
    begin
    end;

    procedure InsertPOSEntrySalesDocReference(POSEntry: Record "POS Entry";SalesDocType: Integer;SalesDocNo: Code[20])
    var
        POSEntrySalesDocLink: Record "POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.Init;
        POSEntrySalesDocLink."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesDocLink."POS Entry Reference Type" := POSEntrySalesDocLink."POS Entry Reference Type"::HEADER;
        POSEntrySalesDocLink."POS Entry Reference Line No." := 0;
        POSEntrySalesDocLink."Sales Document Type" := SalesDocType;
        POSEntrySalesDocLink."Sales Document No" := SalesDocNo;
        POSEntrySalesDocLink.Insert;
    end;

    procedure InsertPOSSalesLineSalesDocReference(POSSalesLine: Record "POS Sales Line";SalesDocType: Integer;SalesDocNo: Code[20])
    var
        POSEntrySalesDocLink: Record "POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.Init;
        POSEntrySalesDocLink."POS Entry No." := POSSalesLine."POS Entry No.";
        POSEntrySalesDocLink."POS Entry Reference Type" := POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE;
        POSEntrySalesDocLink."POS Entry Reference Line No." := POSSalesLine."Line No.";
        POSEntrySalesDocLink."Sales Document Type" := SalesDocType;
        POSEntrySalesDocLink."Sales Document No" := SalesDocNo;
        POSEntrySalesDocLink.Insert;
    end;
}


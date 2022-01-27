codeunit 6151007 "NPR POS Entry S.Doc. Link Mgt."
{
    Access = Internal;
    procedure InsertPOSEntrySalesDocReference(POSEntry: Record "NPR POS Entry"; SalesDocType: Enum "NPR POS Sales Document Type"; SalesDocNo: Code[20])
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.Init();
        POSEntrySalesDocLink."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesDocLink."POS Entry Reference Type" := POSEntrySalesDocLink."POS Entry Reference Type"::HEADER;
        POSEntrySalesDocLink."POS Entry Reference Line No." := 0;
        POSEntrySalesDocLink."Sales Document Type" := SalesDocType;
        POSEntrySalesDocLink."Sales Document No" := SalesDocNo;
        POSEntrySalesDocLink.Insert();
    end;

    procedure InsertPOSSalesLineSalesDocReference(POSSalesLine: Record "NPR POS Entry Sales Line"; SalesDocType: Enum "NPR POS Sales Document Type"; SalesDocNo: Code[20])
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.Init();
        POSEntrySalesDocLink."POS Entry No." := POSSalesLine."POS Entry No.";
        POSEntrySalesDocLink."POS Entry Reference Type" := POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE;
        POSEntrySalesDocLink."POS Entry Reference Line No." := POSSalesLine."Line No.";
        POSEntrySalesDocLink."Sales Document Type" := SalesDocType;
        POSEntrySalesDocLink."Sales Document No" := SalesDocNo;
        POSEntrySalesDocLink.Insert();
    end;
}


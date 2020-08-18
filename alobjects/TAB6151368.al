table 6151368 "CS Rfid Header"
{
    // NPR5.53/CLVA  /20191121  CASE 377563 Object created - NP Capture Service
    // NPR5.54/CLVA  /20200120  CASE 379709 Added fields Closed,Location,"Transferred To","Transferred to Doc","Transferred Date" and "Transferred By"
    // NPR5.55/CLVA  /20200120  CASE 379709 Restructured table. Changed DataPerCompany to No

    Caption = 'CS Rfid Data By Document';
    DataPerCompany = false;

    fields
    {
        field(1;Id;Guid)
        {
            Caption = 'Id';
            Editable = false;
        }
        field(10;Created;DateTime)
        {
            Caption = 'Created';
            Editable = false;
        }
        field(11;"Created By";Code[20])
        {
            Caption = 'Created By';
            Editable = false;
        }
        field(12;"Document Item Quantity";Decimal)
        {
            Caption = 'Document Item Quantity';
            Editable = false;
        }
        field(13;"Shipping Closed";DateTime)
        {
            Caption = 'Shipping Closed';
            Editable = false;
        }
        field(14;"Shipping Closed By";Code[20])
        {
            Caption = 'Shipping Closed By';
            Editable = false;
        }
        field(15;"Receiving Closed";DateTime)
        {
            Caption = 'Receiving Closed';
            Editable = false;
        }
        field(16;"Receiving Closed By";Code[20])
        {
            Caption = 'Receiving Closed By';
            Editable = false;
        }
        field(17;Closed;DateTime)
        {
            Caption = 'Closed';
            Editable = false;
        }
        field(18;"Sell-to Customer No.";Code[20])
        {
            Caption = 'Sell-to Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(19;"Document Type";Option)
        {
            Caption = 'Document Type';
            Editable = false;
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(20;"Document No.";Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(21;"From Company";Text[30])
        {
            Caption = 'From Company';
            Editable = false;
        }
        field(22;"To Company";Text[30])
        {
            Caption = 'To Company';
            Editable = false;
        }
        field(23;"Sell-to Customer Name";Text[50])
        {
            CalcFormula = Lookup(Customer.Name WHERE ("No."=FIELD("Sell-to Customer No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(24;"To Document Type";Option)
        {
            Caption = 'To Document Type';
            Editable = false;
            OptionCaption = ' ,Sales,Purchase';
            OptionMembers = " ",Sales,Purchase;
        }
        field(25;"To Document No.";Code[20])
        {
            Caption = 'To Document No.';
            Editable = false;
        }
        field(26;"Total Tags Shipped";Integer)
        {
            CalcFormula = Count("CS Rfid Lines" WHERE (Id=FIELD(Id),
                                                       "Tag Shipped"=CONST(true)));
            Caption = 'Total Tags Shipped';
            Editable = false;
            FieldClass = FlowField;
        }
        field(27;"Total Tags Received";Integer)
        {
            CalcFormula = Count("CS Rfid Lines" WHERE (Id=FIELD(Id),
                                                       "Tag Received"=CONST(true)));
            Caption = 'Total Tags Received';
            Editable = false;
            FieldClass = FlowField;
        }
        field(28;"Import Tags to Shipping Doc.";Boolean)
        {
            Caption = 'Import Tags to Shipping Doc.';
        }
        field(29;"Warehouse Receipt No.";Code[20])
        {
            Caption = 'Warehouse Receipt No.';
            Editable = false;
            TableRelation = "Warehouse Receipt Header";
        }
        field(30;"Unknown Tags Shipped";Integer)
        {
            CalcFormula = Count("CS Rfid Lines" WHERE (Id=FIELD(Id),
                                                       "Item No."=FILTER(''),
                                                       "Tag Shipped"=CONST(true)));
            Caption = 'Unknown Tags Shipped';
            Editable = false;
            FieldClass = FlowField;
        }
        field(31;"Unknown Tags Received";Integer)
        {
            CalcFormula = Count("CS Rfid Lines" WHERE (Id=FIELD(Id),
                                                       "Item No."=FILTER(''),
                                                       "Tag Received"=CONST(true)));
            Caption = 'Unknown Tags Received';
            Editable = false;
            FieldClass = FlowField;
        }
        field(32;"Total Matched Tags";Integer)
        {
            CalcFormula = Count("CS Rfid Lines" WHERE (Id=FIELD(Id),
                                                       Match=CONST(true)));
            Caption = 'Total Matched Tags';
            Editable = false;
            FieldClass = FlowField;
        }
        field(33;"Document Matched";Boolean)
        {
            Caption = 'Document Matched';
        }
        field(34;"Total Valid Matched Tags";Integer)
        {
            CalcFormula = Count("CS Rfid Lines" WHERE (Id=FIELD(Id),
                                                       Match=CONST(true),
                                                       "Item No."=FILTER(<>'')));
            Caption = 'Total Valid Matched Tags';
            Editable = false;
            FieldClass = FlowField;
        }
        field(35;"Total Unknown Matched Tags";Integer)
        {
            CalcFormula = Count("CS Rfid Lines" WHERE (Id=FIELD(Id),
                                                       Match=CONST(true),
                                                       "Item No."=FILTER('')));
            Caption = 'Total Unknown Matched Tags';
            Editable = false;
            FieldClass = FlowField;
        }
        field(36;"Valid Tags Shipped";Integer)
        {
            CalcFormula = Count("CS Rfid Lines" WHERE (Id=FIELD(Id),
                                                       "Item No."=FILTER(<>''),
                                                       "Tag Shipped"=CONST(true)));
            Caption = 'Valid Tags Shipped';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37;"Valid Tags Received";Integer)
        {
            CalcFormula = Count("CS Rfid Lines" WHERE (Id=FIELD(Id),
                                                       "Item No."=FILTER(<>''),
                                                       "Tag Received"=CONST(true)));
            Caption = 'Valid Tags Received';
            Editable = false;
            FieldClass = FlowField;
        }
        field(38;"Received not Shipped Tags";Integer)
        {
            CalcFormula = Count("CS Rfid Lines" WHERE (Id=FIELD(Id),
                                                       "Item No."=FILTER(<>''),
                                                       "Tag Received"=CONST(true),
                                                       "Tag Shipped"=CONST(false)));
            Caption = 'Received not Shipped Tags';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        CSRfidLines: Record "CS Rfid Lines";
    begin
        Clear(CSRfidLines);
        CSRfidLines.SetRange(Id,Id);
        CSRfidLines.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        Created := CurrentDateTime;
        "Created By" := UserId;
        "From Company" := CompanyName;
    end;

    trigger OnModify()
    begin
        if ("Shipping Closed" <> 0DT) and ("Receiving Closed" <> 0DT) then
          Closed := CurrentDateTime
        else
          Closed := 0DT;

        if ("Shipping Closed" <> 0DT) and ("Receiving Closed" <> 0DT) then begin
          CalcFields("Total Tags Shipped","Total Tags Received");
          "Document Matched" := ("Total Tags Shipped" = "Total Tags Received");
        end;
    end;

    var
        Txt001: Label 'Delete collected tags?';
        Txt002: Label 'Sales Document %1 do not exist.';
        Txt003: Label 'Create Sales Lines? All existing Sales Lines will be deleted.';
        LineNo: Integer;
        SalesLine: Record "Sales Line";
        Txt004: Label 'Total lines created: %1\Unknown tags skipped: %2';
        Txt005: Label 'RFID Document is already shipped';
        Txt006: Label 'Warehouse Receipt do not exist for %1';

    procedure OpenRfidSalesDoc("Doc. Type": Option Ship,Receive;"Doc. No.": Code[20];CustomerNo: Code[20];"To Doc. No.": Code[20])
    var
        CSRfidHeader: Record "CS Rfid Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        QtyCount: Integer;
        CSSetup: Record "CS Setup";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
    begin
        case "Doc. Type" of
          "Doc. Type"::Ship : begin
                                 Clear(CSRfidHeader);
                                 CSRfidHeader.SetRange("Document Type",CSRfidHeader."Document Type"::Sales);
                                 CSRfidHeader.SetRange("Document No.","Doc. No.");
                                 if not CSRfidHeader.FindFirst then begin
                                   Clear(CSRfidHeader);
                                   CSRfidHeader.Init;
                                   CSRfidHeader.Id := CreateGuid();
                                   CSRfidHeader."Document Type" := "Doc. Type";
                                   CSRfidHeader."Document No." := "Doc. No.";
                                   CSRfidHeader."Sell-to Customer No." := CustomerNo;
                                   CSRfidHeader.Insert(true);

                                   CSSetup.Get;
                                   CSRfidHeader."Import Tags to Shipping Doc." := CSSetup."Import Tags to Shipping Doc.";
                                   CSRfidHeader.Modify(true);
                                 end;

                                 SalesLine.SetRange("Document Type",SalesHeader."Document Type"::Order);
                                 SalesLine.SetRange("Document No.","Doc. No.");
                                 SalesLine.SetRange(Type,SalesLine.Type::Item);
                                 if SalesLine.FindSet then begin
                                   repeat
                                     QtyCount := QtyCount + SalesLine.Quantity;
                                   until SalesLine.Next = 0;
                                 end;

                                 if not CSRfidHeader."Import Tags to Shipping Doc." then begin
                                   if CSRfidHeader."Document Item Quantity" <> QtyCount then begin
                                     CSRfidHeader."Document Item Quantity" := QtyCount;
                                     CSRfidHeader.Modify(true);
                                   end;
                                 end;

                                 if CSRfidHeader."Sell-to Customer No." <> CustomerNo then begin
                                   CSRfidHeader."Sell-to Customer No." := CustomerNo;
                                   CSRfidHeader.Modify(true);
                                 end;

                                 PAGE.Run(PAGE::"CS RFID Header Card",CSRfidHeader);
                               end;
          "Doc. Type"::Receive : begin
                                 Clear(CSRfidHeader);
                                 CSRfidHeader.SetRange("Document Type",CSRfidHeader."Document Type"::Sales);
                                 CSRfidHeader.SetRange("Document No.","Doc. No.");
                                 CSRfidHeader.SetFilter("Shipping Closed",'<>%1',0DT);
                                 if not CSRfidHeader.FindFirst then
                                   Error(Txt002,"Doc. No.");

                                 if CSRfidHeader."To Company" = '' then begin
                                   CSRfidHeader."To Company" := CompanyName;
                                   CSRfidHeader.Modify(true);
                                 end;

                                 if CSRfidHeader."To Document Type" = CSRfidHeader."To Document Type"::" " then begin
                                   CSRfidHeader."To Document Type" := CSRfidHeader."To Document Type"::Purchase;
                                   CSRfidHeader.Modify(true);
                                 end;

                                 if CSRfidHeader."To Document No." = '' then begin
                                   CSRfidHeader."To Document No." := "To Doc. No.";
                                   CSRfidHeader.Modify(true);
                                 end;

                                 CSSetup.Get;
                                 if CSSetup."Use Whse. Receipt" and (CSRfidHeader."Warehouse Receipt No." = '') then begin
                                   Clear(WarehouseReceiptLine);
                                   WarehouseReceiptLine.SetRange("Source Type",39);
                                   WarehouseReceiptLine.SetRange("Source Subtype",WarehouseReceiptLine."Source Subtype"::"1");
                                   WarehouseReceiptLine.SetRange("Source No.",CSRfidHeader."To Document No.");
                                   if WarehouseReceiptLine.FindFirst then begin
                                     CSRfidHeader."Warehouse Receipt No." := WarehouseReceiptLine."No.";
                                     CSRfidHeader.Modify(true);
                                   end else
                                     Error(Txt006,CSRfidHeader."To Document No.");
                                 end;

                                 PAGE.Run(PAGE::"CS RFID Header Card",CSRfidHeader);
                               end;
        end;
    end;

    procedure DeleteRfidDocLines()
    var
        CSRfidLines: Record "CS Rfid Lines";
        CSShippingHandlingRfid: Record "CS Transfer Handling Rfid";
    begin
        if "Shipping Closed" <> 0DT then
          Error(Txt005);

        if not Confirm(Txt001,true) then
          exit;

        Clear(CSRfidLines);
        CSRfidLines.SetRange(Id,Id);
        CSRfidLines.DeleteAll();

        Clear(CSShippingHandlingRfid);
        CSShippingHandlingRfid.SetRange("Rfid Header Id",Id);
        CSShippingHandlingRfid.DeleteAll();

        "Import Tags to Shipping Doc." := false;
        "Shipping Closed" := 0DT;
        "Shipping Closed By" := '';
        "Receiving Closed" := 0DT;
        "Receiving Closed By" := '';
        Modify(true);
    end;

    procedure CreateSalesLinesByRfidDocLines()
    var
        CSRfidLinesQy: Query "CS Rfid Lines";
        LineCounter: Integer;
        LineCounterUnknown: Integer;
    begin
        if not "Import Tags to Shipping Doc." then
          exit;

        if "Shipping Closed" <> 0DT then
          Error(Txt005);

        if GuiAllowed then
          if not Confirm(Txt003,true) then
            exit;

        SalesLine.SetRange("Document Type",SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.","Document No.");
        SalesLine.DeleteAll(true);

        LineNo := 0;
        LineCounter := 0;
        LineCounterUnknown := 0;
        CSRfidLinesQy.SetRange(Id,Id);
        CSRfidLinesQy.Open;
        while CSRfidLinesQy.Read do
        begin
          if CSRfidLinesQy.Item_No <> ''  then begin
            LineCounter += CSRfidLinesQy.Count_;
            InsertSalesLine();
            SalesLine.Validate(Type,SalesLine.Type::Item);
            SalesLine.Validate("No.",CSRfidLinesQy.Item_No);
            SalesLine.Validate("Variant Code",CSRfidLinesQy.Variant_Code);
            SalesLine.Validate(Quantity,CSRfidLinesQy.Count_);
            SalesLine.Modify(true);
          end else
            LineCounterUnknown += 1;
        end;

        "Document Item Quantity" := LineCounter;
        Modify(true);

        if GuiAllowed then
          Message(Txt004,LineCounter,LineCounterUnknown);
    end;

    local procedure InsertSalesLine()
    begin
        Clear(SalesLine);
        SalesLine.Init;
        SalesLine.Validate("Document Type",SalesLine."Document Type"::Order);
        SalesLine.Validate("Document No.","Document No.");
        LineNo += 10000;
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);
    end;

    procedure InsertSalesLineStatus()
    begin
        if "Shipping Closed" <> 0DT then
          Error(Txt005);

        if "Import Tags to Shipping Doc." then
          "Import Tags to Shipping Doc." := false
        else
          "Import Tags to Shipping Doc."  := true;
    end;

    procedure TransferWhseReceiptLines()
    var
        CSRfidLines: Record "CS Rfid Lines";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseReceiptHeader: Record "Warehouse Receipt Header";
    begin
        WarehouseReceiptHeader.Get("Warehouse Receipt No.");

        CSRfidLines.SetRange(Id,Id);
        CSRfidLines.SetFilter("Item No.",'<>%1','');
        CSRfidLines.SetRange(Match,true);
        if CSRfidLines.FindFirst then begin
          repeat
            WhseReceiptLine.SetCurrentKey("Source Type","Source Subtype","Source No.","Source Line No.");
            WhseReceiptLine.SetRange("No.","Warehouse Receipt No.");
            WhseReceiptLine.SetRange("Item No.",CSRfidLines."Item No.");
            WhseReceiptLine.SetRange("Variant Code",CSRfidLines."Variant Code");
            if WhseReceiptLine.FindFirst then begin
              WhseReceiptLine.Validate("Qty. to Receive",WhseReceiptLine."Qty. to Receive" + 1);
              WhseReceiptLine.Modify(true);

              CSRfidLines."Transferred to Whse. Receipt" := true;
              CSRfidLines.Modify(true);
            end;
          until CSRfidLines.Next = 0;
        end;
    end;
}


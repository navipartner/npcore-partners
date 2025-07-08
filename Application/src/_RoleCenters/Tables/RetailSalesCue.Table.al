table 6059811 "NPR Retail Sales Cue"
{
    Access = Internal;
    Caption = 'NaviConnect Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Import Pending"; Integer)
        {
            CalcFormula = Count("NPR Nc Import Entry" WHERE(Imported = CONST(false), "Import Type" = field("Import Type Filter")));
            Caption = 'Import Unprocessed';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Import Type Filter"; Code[20])
        {
            Caption = 'Import Type Filter';
            FieldClass = FlowFilter;
        }
        field(15; "Tasks Unprocessed"; Integer)
        {
            CalcFormula = Count("NPR Nc Task" WHERE(Processed = CONST(false)));
            Caption = 'Tasks Unprocessed';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Sales Orders"; Integer)
        {
            CalcFormula = Count("Sales Header" WHERE("Document Type" = FILTER(Order)));
            Caption = 'Sales Orders';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Sales Quotes"; Integer)
        {
            CalcFormula = Count("Sales Header" WHERE("Document Type" = FILTER(Quote)));
            Caption = 'Sales Quotes';
            FieldClass = FlowField;
        }
        field(22; "Sales Return Orders"; Integer)
        {
            CalcFormula = Count("Sales Header" WHERE("Document Type" = FILTER("Return Order")));
            Caption = 'Sales Return Orders';
            FieldClass = FlowField;
        }
        field(23; "Magento Orders"; Integer)
        {
            CalcFormula = Count("Sales Header" WHERE("Document Type" = FILTER(Order),
                                                      "NPR External Order No." = FILTER(<> '')));
            Caption = 'Magento Orders';
            FieldClass = FlowField;
        }
        field(30; "Daily Sales Orders"; Integer)
        {
            CalcFormula = Count("Sales Header" WHERE("Document Type" = FILTER(Order),
                                                      "Posting Date" = FIELD("Date Filter")));
            Caption = 'Daily Sales Orders';
            FieldClass = FlowField;
        }
        field(31; "Daily Sales Invoices"; Integer)
        {
            CalcFormula = Count("Sales Invoice Header" WHERE("Posting Date" = FIELD("Date Filter")));
            Caption = 'Daily Sales Invoices';
            FieldClass = FlowField;
        }
        field(32; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(33; "Processed Error Tasks"; Integer)
        {
            CalcFormula = Count("NPR Nc Task" WHERE("Process Error" = FILTER(true)));
            Caption = 'Processed Error Tasks';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Pending Inc. Documents"; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE("Document Type" = CONST(" "),
                                                           "Document No." = CONST('')));
            Caption = 'Pending Inc. Documents';
            Description = 'NPR5.30';
            FieldClass = FlowField;
        }
        field(45; "Failed Webshop Payments"; Integer)
        {
            CalcFormula = Count("NPR Magento Payment Line" WHERE("Document Table No." = CONST(112),
                                                              "Payment Gateway Code" = FILTER(<> ''),
                                                              "Date Captured" = FILTER(= 0D)));
            Caption = 'Failed Webshop Payments';
            Description = 'NPR5.53';
            FieldClass = FlowField;
        }
        field(100; "Blocked Customers"; Integer)
        {
            Caption = 'Blocked Customers';
            CalcFormula = Count(Customer WHERE(Blocked = filter(All)));
            FieldClass = FlowField;
        }
        field(101; "Imported Magento SOs"; Integer)
        {
            Caption = 'Imported Magento Sales Orders';
            FieldClass = FlowField;
            CalcFormula = Count("Sales Header" where("Salesperson Code" = filter('WEB')));
            Editable = false;
        }
        field(102; "Retail Vouchers"; Integer)
        {
            Caption = 'Retail Vouchers';
            FieldClass = FlowField;
            CalcFormula = Count("NPR NpRv Voucher");
            Editable = false;
        }
        field(103; "Gift Vouchers"; Integer)
        {
            Caption = 'Gift Vouchers';
            FieldClass = FlowField;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Gift voucher table won''t be used anymore.';
        }
        field(104; "Credit Vouchers"; Integer)
        {
            Caption = 'Credit Vouchers';
            FieldClass = FlowField;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Credit voucher table won''t be used anymore.';
        }
        field(105; "Task List"; Integer)
        {
            Caption = 'Task List';
            FieldClass = FlowField;
            CalcFormula = count("NPR Nc Task" where(Processed = filter(false)));
            Editable = false;
        }
        field(106; "Shipped Sales Orders"; Integer)
        {
            Caption = 'Shipped Sales Orders';
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Shipped Not Invoiced" = filter(true)));
            Editable = false;
        }
        field(107; "Failed imports"; Integer)
        {
            Caption = 'Failed imports in the import list';
            FieldClass = FlowField;
            CalcFormula = count("NPR Nc Import Entry" where("Runtime Error" = const(true), "Import Type" = field("Import Type Filter")));
            Editable = false;
        }
        field(108; "My Incoming Documents"; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE(Processed = CONST(false)));
            Caption = 'My Incoming Documents';
            FieldClass = FlowField;
            ObsoleteReason = 'Moved to table 6151247 "NPR POS Entry Cue."';
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
        }
        field(109; "Sales Credit Memos"; Integer)
        {
            Caption = 'Sales Credit Memos';
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" WHERE("Document Type" = FILTER("Credit Memo")));
        }
        field(110; "Posted Sales Invoices"; Integer)
        {
            Caption = 'Posted Sales Invoices';
            FieldClass = FlowField;
            CalcFormula = count("Sales Invoice Header");
        }
        field(111; "Collect Document List"; Integer)
        {
            Caption = 'Collect Document List';
            FieldClass = FlowField;
            CalcFormula = count("NPR NpCs Document");
        }
        field(112; "Purchase Order List"; Integer)
        {
            Caption = 'Purchase Order List';
            FieldClass = FlowField;
            CalcFormula = count("Purchase Header" where("Document Type" = filter(Order)));
        }
#if not BC17
        field(200; "Spfy CC Orders - Unproc."; Integer)
        {
            Caption = 'Unprocessed Shopify CC Orders';
            FieldClass = FlowField;
            CalcFormula = Count("NPR Spfy C&C Order" where(Status = const(Error)));
            Editable = false;
            ObsoleteState = Pending;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'Moved to a PTE as it was a customization for a specific customer.';
        }
#endif
        field(300; "Failed Inc Ecom Sales Orders"; Integer)
        {
            Caption = 'Failed Incoming Ecom Sales Orders';
            FieldClass = FlowField;
            CalcFormula = count("NPR Inc Ecom Sales Header" where("Creation Status" = const(Error), "Document Type" = const(Order)));
            Editable = false;
        }
        field(301; "Daily Inc Ecom Sales Orders"; Integer)
        {
            Caption = 'Daily Incoming Ecommerce Sales Orders';
            CalcFormula = Count("NPR Inc Ecom Sales Header" WHERE("Document Type" = FILTER(Order),
                                                      "Received Date" = FIELD("Date Filter")));
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    internal procedure SetActionableImportEntryTypeFilter()
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        Rec.SetFilter("Import Type Filter", ImportType.GetActionableTypeFilter());
    end;
}

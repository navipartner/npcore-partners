table 6151190 "NPR Inc Ecom Sales Doc Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Incoming Ecommerce Sales Document Setup';
    Access = Public;
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    LookupPageId = "NPR Inc Ecom Sales Doc Setup";
    DrillDownPageId = "NPR Inc Ecom Sales Doc Setup";
#endif

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Max Doc Process Retry Count"; Integer)
        {
            Caption = 'Max. Document Process Retry Count';
            DataClassification = CustomerContent;
            InitValue = 2;
        }
        field(3; "Auto Proc Sales Order"; Boolean)
        {
            Caption = 'Auto Process Sales Order';
            DataClassification = CustomerContent;
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
            trigger OnValidate()
            var
                EcomSalesDocProcess: Codeunit "NPR EcomSalesDocProcess";
            begin
                EcomSalesDocProcess.HandleSalesOrderProcessJQScheduleConfirmation(Rec."Auto Proc Sales Order");
            end;
#endif
        }
        field(4; "Proc Sales Order On Receive"; Boolean)
        {
            Caption = 'Process Sales Order On Receive';
            DataClassification = CustomerContent;
        }
        field(6; "Auto Proc Sales Ret Order"; Boolean)
        {
            Caption = 'Auto Process Sales Return Order';
            DataClassification = CustomerContent;
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
            trigger OnValidate()
            var
                EcomSalesDocProcess: Codeunit "NPR EcomSalesDocProcess";
            begin
                EcomSalesDocProcess.HandleSalesReturnOrderProcessJQScheduleConfirmation(Rec."Auto Proc Sales Ret Order");
            end;
#endif
        }
        field(7; "Proc Sales Ret Ord On Receive"; Boolean)
        {
            Caption = 'Process Sales Return Order On Receive';
            DataClassification = CustomerContent;
        }
        field(8; "Def. Sales Location Code"; Code[10])
        {
            Caption = 'Def. Sales Location Code';
            TableRelation = Location.Code;
            DataClassification = CustomerContent;
        }
        field(9; "Release Sale Ord After Prc"; Boolean)
        {
            Caption = 'Release Sales Order After Process';
            DataClassification = CustomerContent;
        }
        field(10; "Release Sale Ret Ord After Prc"; Boolean)
        {
            Caption = 'Release Sales Return Order After Process';
            DataClassification = CustomerContent;
        }
        field(12; "Customer Mapping"; Enum "NPR IncEcomDocCustomerMapping")
        {
            Caption = 'Customer Mapping';
            DataClassification = CustomerContent;
        }
        field(13; "Customer Update Mode"; Enum "NPR IncEcomDocCustUpdateMode")
        {
            Caption = 'Customer Update Mode';
            DataClassification = CustomerContent;
        }
        field(14; "Def Cust Config Template Code"; Code[10])
        {
            Caption = 'Def. Customer Config. Template Code';
            DataClassification = CustomerContent;
            TableRelation = "Config. Template Header".Code WHERE("Table ID" = CONST(18));
        }
        field(15; "Def. Customer Template Code"; Code[20])
        {
            Caption = 'Def. Customer Template Code';
            DataClassification = CustomerContent;
            TableRelation = "Customer Templ.";
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
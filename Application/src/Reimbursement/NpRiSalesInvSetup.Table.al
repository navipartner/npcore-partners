﻿table 6151110 "NPR NpRi Sales Inv. Setup"
{
    Access = Internal;
    Caption = 'Sales Invoice Reimbursement Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpRi Reimbursement Templ.";
        }
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(20; "Invoice per"; Option)
        {
            Caption = 'Invoice per';
            DataClassification = CustomerContent;
            OptionCaption = 'Period,Document';
            OptionMembers = Period,Document;

            trigger OnValidate()
            begin
                case "Invoice per" of
                    "Invoice per"::Period:
                        begin
                            "Invoice Posting Date" := "Invoice Posting Date"::Reimbursement;
                        end;
                    "Invoice per"::Document:
                        begin
                            "Invoice Posting Date" := "Invoice Posting Date"::Document;
                        end;
                end;
            end;
        }
        field(30; "Invoice Posting Date"; Option)
        {
            Caption = 'Invoice Posting Date';
            DataClassification = CustomerContent;
            OptionCaption = 'Reimbursement,Document';
            OptionMembers = Reimbursement,Document;
        }
        field(40; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(50; "Post Immediately"; Boolean)
        {
            Caption = 'Post Immediately';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Template Code")
        {
        }
    }

    trigger OnDelete()
    var
        NpRiSalesInvoiceLine: Record "NPR NpRi Sales Inv. Setup Line";
    begin
        NpRiSalesInvoiceLine.SetRange("Template Code", "Template Code");
        if NpRiSalesInvoiceLine.FindFirst() then
            NpRiSalesInvoiceLine.DeleteAll();
    end;
}


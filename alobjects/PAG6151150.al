page 6151150 "Customer GDPR Setup"
{
    // NPR5.52/JAKUBV/20191022  CASE 358656 Transport NPR5.52 - 22 October 2019
    // NPR5.53/ZESO/20200115 CASE 358656 Added Fields Customer Posting Group Filter, Gen. Bus. Posting Group Filter, No of Customers and Page Action 'Extract Customers'

    Caption = 'Customer GDPR Setup';
    PageType = Card;
    SourceTable = "Customer GDPR SetUp";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Anonymize After";"Anonymize After")
                {
                }
                field("Customer Posting Group Filter";"Customer Posting Group Filter")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.53 [358656]
                        if PAGE.RunModal(0,CustPostingGrp) = ACTION::LookupOK then
                          "Customer Posting Group Filter" := CustPostingGrp.Code;
                        //+NPR5.53 [358656]
                    end;
                }
                field("Gen. Bus. Posting Group Filter";"Gen. Bus. Posting Group Filter")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.53 [358656]
                        if PAGE.RunModal(0,GenBusPostingGrp) = ACTION::LookupOK then
                         "Gen. Bus. Posting Group Filter" := GenBusPostingGrp.Code;
                        //+NPR5.53 [358656]
                    end;
                }
                field("No of Customers";"No of Customers")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Extract Customers")
            {
                Caption = 'Extract Customers';
                Image = Customer;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    GDPRSetup: Record "Customer GDPR SetUp";
                    DateFormulaTxt: Text[250];
                    VarPeriod: DateFormula;
                    VarEntryNo: Integer;
                    Window: Dialog;
                    Customer: Record Customer;
                    CLE: Record "Cust. Ledger Entry";
                    CustToAnonymize: Record "Customers to Anonymize";
                    ILE: Record "Item Ledger Entry";
                    NoCLE: Boolean;
                    NoILE: Boolean;
                begin

                    CustToAnonymize.Reset;
                    if CustToAnonymize.FindFirst then
                      if not Confirm(Text000,false) then
                        exit;


                    CustToAnonymize.Reset;
                    CustToAnonymize.DeleteAll;


                    if GDPRSetup.Get then;

                    DateFormulaTxt := '-' + Format(GDPRSetup."Anonymize After");
                    Evaluate(VarPeriod,DateFormulaTxt);


                    VarEntryNo := 1;
                    Window.Open('Customer #1##################');
                    Customer.Reset;
                    Customer.SetRange(Customer.Anonymized,false);
                    Customer.SetFilter(Customer."Customer Posting Group",GDPRSetup."Customer Posting Group Filter");
                    Customer.SetFilter(Customer."Gen. Bus. Posting Group",GDPRSetup."Gen. Bus. Posting Group Filter");
                    if Customer.FindSet then
                      repeat
                        Window.Update(1,Customer."No.");


                        if (Today - Customer."Last Date Modified") >= (Today - CalcDate(VarPeriod,Today)) then begin
                          NoCLE := false;
                          NoILE := false;
                          CLE.Reset;
                          CLE.SetCurrentKey("Customer No.","Posting Date","Currency Code");
                          CLE.SetRange("Customer No.",Customer."No.");
                          CLE.SetFilter("Posting Date",'>%1',CalcDate(VarPeriod,Today));
                          if not CLE.FindFirst then
                            NoCLE := true;

                          ILE.Reset;
                          ILE.SetCurrentKey("Source Type","Source No.","Item No.","Variant Code","Posting Date");
                          ILE.SetRange(ILE."Source Type",ILE."Source Type"::Customer);
                          ILE.SetRange(ILE."Source No.",Customer."No.");
                          ILE.SetFilter("Posting Date",'>%1',CalcDate(VarPeriod,Today));
                          if not ILE.FindFirst then
                            NoILE := true;




                          if NoILE and NoCLE then begin
                            CustToAnonymize.Init;
                            CustToAnonymize."Entry No" := VarEntryNo;
                            CustToAnonymize."Customer No" := Customer."No.";
                            CustToAnonymize."Customer Name" := Customer.Name;
                            CustToAnonymize.Insert;
                            VarEntryNo += 1;
                          end;
                        end;
                      until Customer.Next =0;
                    Window.Close;
                    Message('Completed');
                end;
            }
        }
    }

    var
        GenBusPostingGrp: Record "Gen. Business Posting Group";
        CustPostingGrp: Record "Customer Posting Group";
        Text000: Label 'Existing Customers will be lost, do you want to continue?';
}


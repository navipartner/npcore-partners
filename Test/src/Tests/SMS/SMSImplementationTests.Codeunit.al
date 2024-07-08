codeunit 85111 "NPR SMS Implementation Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MakeMessage()
    var
        Customer: Record Customer;
        SMSTemplateHeader: Record "NPR SMS Template Header";
        SMSManagement: Codeunit "NPR SMS Management";
        SMSMessage: Text[250];
        ExpectedSMSMessage: Text[250];

    begin
        //[Scenario] Create SMS message with the SMS template and check output.

        // [When] Create SMS setup, new customer and new SMS template
        CreateCustomer(Customer);
        CreateSMSTemplate(SMSTemplateHeader, 'SMS_TEST', Database::Customer);

        // [When] Create SMS Message for given template and Customer
        SMSMessage := SMSManagement.MakeMessage(SMSTemplateHeader, Customer);

        // [When] SMS Message that we are expecting
        ExpectedSMSMessage := BuildSMSMessageTargetTxt(Customer);

        // [Then] Check if the message output is the same as defined by the template.
        Assert.AreEqual(ExpectedSMSMessage, SMSMessage, 'MakeMessage');
    end;

    local procedure CreateCustomer(var Cust: Record Customer)
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomer(Cust);
        Cust.Name := 'Test Customer';
        Cust."Address" := 'Unnamed Street';
        Cust."Address 2" := 'Last House on the Left';
        Cust.City := 'Copenhagen';
        Cust.Modify();
    end;

    local procedure CreateSMSTemplate(var TemplateHeader: Record "NPR SMS Template Header"; TemplateCode: Code[10]; TableNo: Integer)
    var
        TemplateLine: Record "NPR SMS Template Line";
    begin
        if not TemplateHeader.Get(TemplateCode) then begin
            TemplateHeader.Init();
            TemplateHeader.Code := TemplateCode;
            TemplateHeader.Insert();
        end else begin
            TemplateHeader.Description := TemplateCode;
            TemplateHeader."Table No." := TableNo;
            TemplateHeader."Alt. Sender" := 'NPR SMS';
            TemplateHeader."Recipient Type" := "NPR SMS Recipient Type"::Field;
            TemplateHeader.Recipient := '{9}'; // Field {9} is Phone No.
            TemplateHeader.Modify();
        end;

        TemplateLine.SetRange("Template Code", TemplateCode);
        TemplateLine.DeleteAll();

        InsertTemplateLines(TemplateCode, 10000, 'Hi {2},');
        InsertTemplateLines(TemplateCode, 20000, 'Your address is {5}, {6}, {7}');
        InsertTemplateLines(TemplateCode, 30000, 'Best Regards,');
        InsertTemplateLines(TemplateCode, 40000, 'Customer Care Team.');
    end;

    local procedure InsertTemplateLines(TemplateCode: Code[10]; LineNo: Integer; SMSText: Text[250])
    var
        TemplateLine: Record "NPR SMS Template Line";
    begin
        TemplateLine.Init();
        TemplateLine."Template Code" := TemplateCode;
        TemplateLine."Line No." := LineNo;
        TemplateLine."SMS Text" := SMSText;
        TemplateLine.Insert();
    end;

    local procedure BuildSMSMessageTargetTxt(Cust: Record Customer) Message: Text[250]
    var
        Char13: Char;
        Char10: Char;
    begin
        Message := '';
        Char13 := 13;
        Char10 := 10;

        Message += 'Hi ' + Cust.Name + ',';
        Message += Format(Char13) + Format(Char10);
        Message += 'Your address is ' + Cust.Address + ', ' + Cust."Address 2" + ', ' + Cust.City;
        Message += Format(Char13) + Format(Char10);
        Message += 'Best Regards,';
        Message += Format(Char13) + Format(Char10);
        Message += 'Customer Care Team.';
        exit(Message);
    end;
}
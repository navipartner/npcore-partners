export interface WorkflowPopupHandler {
    numpad(content: any, title?: string): Promise<any>;
    intpad(content: any, title?: string): Promise<any>;
    datepad(content: any, title?: string): Promise<any>;
    stringpad(content: any, title?: string): Promise<any>;
    passwordpad(content: any, title?: string): Promise<any>;
    input(content: any, title?: string): Promise<any>;
    password(content: any, title?: string): Promise<any>;
    menu(content: any, title?: string): Promise<any>;
    optionsMenu(content: any, title?: string): Promise<any>;
    message(content: any, title?: string): Promise<any>;
    confirm(content: any, title?: string): Promise<any>;
    error(content: any, title?: string): Promise<any>;
    calendarPlusLines(content: any, title?: string): Promise<any>;
    configuration(content: any, title?: string): Promise<any>;
    configurationTable(content: any, title?: string): Promise<any>;
    timeout(content: any, title?: string): Promise<any>;
    open(content: any, title?: string): Promise<any>;
    simplePayment(content: any): Promise<any>;
    mobilePay(content: any): Promise<any>; 
}

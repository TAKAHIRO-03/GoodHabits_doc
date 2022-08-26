describe("Login", () => {
  it("normal", () => {
    cy.visit("/login");
    cy.get("input[name=email]").type("hoge@hoge.com");
    cy.get("input[name=password]").type(`TestTest!1{enter}`);
    cy.contains("OK").click();

    // TODO verify cookies(jwt)

    cy.url().should("include", "/plannedTask");
  });
  it("nothing email", () => {
    cy.visit("/login");
    cy.get("input[name=email]").focus().blur();
    cy.get("input[name=password]").type(`TestTest!1{enter}`);
    cy.get("button[type=submit]").should("have.attr", "disabled");
  });
  it("nothing password", () => {
    cy.visit("/login");
    cy.get("input[name=email]").type("hoge@hoge.com{enter}");
    cy.get("input[name=password]").focus().blur();
    cy.get("button[type=submit]").should("have.attr", "disabled");
  });
});

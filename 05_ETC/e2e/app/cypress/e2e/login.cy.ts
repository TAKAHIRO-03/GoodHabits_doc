describe("Login", () => {
  beforeEach(() => {
    cy.visit("/login");
  });

  it("normal", () => {
    cy.visit("/login");
    cy.get("input[name=email]").type("hoge@hoge.com");
    cy.get("input[name=password]").type(`TestTest!1{enter}`);
    cy.contains("OK").click();

    // TODO verify cookies(jwt)

    cy.url().should("include", "/task");
  });
});

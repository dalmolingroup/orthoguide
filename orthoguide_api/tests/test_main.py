# test_main.py

import pytest
from fastapi.testclient import TestClient

def test_get_root_with_valid_genes(test_app):
    """
    Tests the /get_root endpoint with a valid request for two genes.
    It checks for a successful status code and verifies the content of the response.
    """
    # Make a GET request to the test client
    response = test_app.get("/get_root?genes=NRP1,CDK6")
    
    assert response.status_code == 200
    
    data = response.json()
    
    assert len(data) == 2

    results_by_gene = {item['queryItem']: item for item in data}
    
    assert "NRP1" in results_by_gene
    assert "CDK6" in results_by_gene
    
    assert results_by_gene["NRP1"]["clade_name"] == "Ambulacraria"
    assert results_by_gene["CDK6"]["clade_name"] == "Metamonada"
    
    print("\nTest 'test_get_root_with_valid_genes' passed successfully!")

def test_get_root_with_no_genes(test_app):
    """
    Tests the /get_root endpoint without providing the 'genes' query parameter.
    It checks that the API returns a 400 Bad Request error.
    """
    response = test_app.get("/get_root")
    assert response.status_code == 400
    assert response.json() == {"detail": "Please provide a comma-separated list of genes in the 'genes' parameter."}
    print("Test 'test_get_root_with_no_genes' passed successfully!")

def test_get_root_with_nonexistent_gene(test_app):
    """
    Tests the /get_root endpoint with a gene that is not in the database.
    It should return an empty list.
    """
    response = test_app.get("/get_root?genes=XYZ")
    assert response.status_code == 200
    assert response.json() == []
    print("Test 'test_get_root_with_nonexistent_gene' passed successfully!")


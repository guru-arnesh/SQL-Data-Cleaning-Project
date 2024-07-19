**Nashville Housing Data Cleaning Project**
This project showcases a comprehensive data cleaning process on a dataset from the Nashville housing market using SQL. The primary objective is to ensure data accuracy, consistency, and readiness for analysis. The project includes the following key tasks:

**Date Standardization:**
Converted the SaleDate field to a standardized SaleDateConverted date format.

**Handling Missing Property Addresses:**
Populated missing PropertyAddress fields using self-join techniques to infer addresses based on matching ParcelID.

**Parsing Addresses:**
Split PropertyAddress into separate columns for address and city.
Split OwnerAddress into separate columns for address, city, and state using PARSENAME.

**Standardizing Boolean Values:**
Updated the SoldAsVacant field to replace 'Y'/'N' values with 'Yes'/'No' for better readability.

**Removing Duplicates:**
Identified and removed duplicate records based on ParcelID, PropertyAddress, SalePrice, SaleDateConverted, and LegalReference.

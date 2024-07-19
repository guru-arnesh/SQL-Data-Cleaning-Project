SELECT TOP (100)
[UniqueID ],
[ParcelID],
[LandUse],
[PropertyAddress],
[SaleDateConverted],
[SalePrice],
[LegalReference],
[SoldAsVacant],
[OwnerName],
[OwnerAddress],
[Acreage],
[TaxDistrict],
[LandValue],
[BuildingValue],
[Totalvalue],
[YearBuilt],
[Bedrooms],
[FullBath],
[HalfBath]

FROM [Portfolio Project]..NashvilleHousing

------------------------------------------------------------------------------------

--STANDARDIZE DATE FORMAT

Select SaleDateConverted
from [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS

SELECT PropertyAddress
FROM [Portfolio Project]..NashvilleHousing
WHERE PropertyAddress is null
--ORDER BY ParcelID


-- self join is performed to check the distinct values differentiated by UniqueID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing AS a  
JOIN [Portfolio Project]..NashvilleHousing AS b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing AS a  
JOIN [Portfolio Project]..NashvilleHousing AS b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]

------------------------------------------------------------------------------------

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (address, city, state)

SELECT PropertyAddress
FROM [Portfolio Project]..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address  --(-1, is done to remove the comma)
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM [Portfolio Project]..NashvilleHousing

USE [Portfolio Project];
GO

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--OWNER ADDRESS


SELECT *
FROM [Portfolio Project]..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
from [Portfolio Project]..NashvilleHousing

------------------------------------------------------------------------------------

--CHANGE Y and N to YES and NO IN "Sold as Vacant" FIELD

SELECT DISTINCT (SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant) as Count
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [Portfolio Project]..NashvilleHousing

USE [Portfolio Project]
GO

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
	                    ELSE SoldAsVacant
	                    END


------------------------------------------------------------------------------------

--REMOVING DUPLICATES

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY Parcelid,
            PropertyAddress,
            SalePrice,
            SaleDateConverted,
            LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM [Portfolio Project]..NashvilleHousing
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
order by PropertyAddress
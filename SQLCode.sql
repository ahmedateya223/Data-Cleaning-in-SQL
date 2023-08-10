select * 
from NashvilleHousing;

-- Change SaleDate format

update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate);

select SaleDate
from NashvilleHousing; -- not working 

-- Trying another approach

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate);

select SaleDateConverted
from NashvilleHousing;     -- it works

-- Populate PropertyAddress field

select ParcelID, PropertyAddress
from NashvilleHousing
order by ParcelID; -- same ParcelIDs have same PropertyAddresses


select 
	a.UniqueID, 
	a.ParcelID, 
	a.PropertyAddress, 
	b.UniqueID, 
	b.ParcelID, 
	b.PropertyAddress
from 
	NashvilleHousing a inner join NashvilleHousing b
on  
	a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from 
	NashvilleHousing a inner join NashvilleHousing b
on
	a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- Breaking out composite addresses into individual ones(address, city)

select 
	PropertyAddress, 
	LEFT(PropertyAddress,CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) as city
from NashvilleHousing;

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255),
	PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress)-1)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))

select PropertyAddress, PropertySplitAddress, PropertySplitCity
from NashvilleHousing


-- Breaking out composite addresses into individual ones(address, city, state)

select 
	OwnerAddress, 
	PARSENAME(replace(OwnerAddress,',','.'),1),
	PARSENAME(replace(OwnerAddress,',','.'),2),
	PARSENAME(replace(OwnerAddress,',','.'),3)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1);

select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from NashvilleHousing

-- Remove unused fields

alter table NashvilleHousing
drop column PropertyAddress, OwnerAddress

-- Change Y and N to Yes and No in SoldAsVacant field to standarize format

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from 
	NashvilleHousing
group by SoldAsVacant


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-- Remove duplicate rows

with CTE as (
select *, ROW_NUMBER() over(
				partition by ParcelID, 
				LandUse, 
				PropertyAddress, 
				SaleDate, 
				SalePrice, 
				LegalReference order by UniqueID) as rn
from NashvilleHousing
)

delete from CTE
where rn > 1

select * from CTE where rn > 1




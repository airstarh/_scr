let currentPage = 1;
const productsContainer = document.getElementById("products");
const paginationContainer = document.getElementById("pagination");

function loadProducts(page = 1) {
  currentPage = page;
  const params = new URLSearchParams({
    page: page,
    limit: 10,
    q: document.getElementById("search").value,
    price_from: document.getElementById("priceFrom").value,
    price_to: document.getElementById("priceTo").value,
    category_id: document.getElementById("category").value,
    in_stock: document.getElementById("inStock").checked ? "true" : "",
    rating_from: document.getElementById("ratingFrom").value,
    sort: document.getElementById("sort").value,
  });

  // Убираем пустые параметры из запроса
  for (let [key, value] of params.entries()) {
    if (value === "" || value === "false") {
      params.delete(key);
    }
  }

  fetch(`/api/products.php?${params}`)
    .then((response) => response.json())
    .then((data) => {
      displayProducts(data.data);
      renderPagination(data.pagination);
    })
    .catch((error) => {
      console.error("Error:", error);
      productsContainer.innerHTML = "<p>Ошибка загрузки товаров</p>";
    });
}

function displayProducts(products) {
  if (products.length === 0) {
    productsContainer.innerHTML = "<p>Товары не найдены</p>";
    return;
  }

  const html = products
    .map(
      (product) => `
        <div class="product">
            <h3>${product.name}</h3>
            <p>Цена: ${product.price} руб.</p>
            <p>Категория: ${product.category_id}</p>
            <p>В наличии: ${product.in_stock ? "Да" : "Нет"}</p>
            <p>Рейтинг: ${product.rating}/5</p>
        </div>
    `,
    )
    .join("");

  productsContainer.innerHTML = html;
}

function renderPagination(pagination) {
  const { current_page, total_pages } = pagination;
  let paginationHTML = "";

  for (let i = 1; i <= total_pages; i++) {
    paginationHTML += `
            <button
                onclick="loadProducts(${i})"
                class="${i === current_page ? "active" : ""}"
            >
                ${i}
            </button>
        `;
  }

  paginationContainer.innerHTML = paginationHTML;
}

// Загружаем товары при загрузке страницы
document.addEventListener("DOMContentLoaded", loadProducts);

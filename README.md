# Rack API Asíncrona de Productos

Este proyecto es una **API REST en Ruby usando Rack**, sin Rails, que permite autenticarse, crear productos de forma asíncrona y consultarlos. Incluye compresión GZIP, autenticación con JWT, archivos estáticos (`openapi.yaml` y `AUTHORS`) y una simulación de persistencia en memoria.

---

## Tecnologías y dependencias

* Ruby (~> 3.0)
* [Rack](https://github.com/rack/rack) 2.2
* [Thin](https://github.com/macournoyer/thin) 1.8
* [JWT](https://github.com/jwt/ruby-jwt) 3.1
* [RSpec](https://github.com/rspec/rspec) 3.13
* [Daemons](https://github.com/thuehlinger/daemons) y EventMachine para manejo de hilos/asíncrono

---

## 🗂 Estructura del proyecto

```
.
├── Gemfile 
├── Gemfile.lock
├── config.ru                 # Entry point de Rack
├── config
│   └── routes.rb             # Definición de rutas
├── app
│   ├── controllers
│   │   ├── auth_controller.rb
│   │   └── products_controller.rb
│   ├── middlewares
│   │   ├── auth_middleware.rb
│   │   └── gzip_middleware.rb
│   ├── models
│   │   └── product.rb        # Persistencia de productos en memoria
│   ├── services
│   │   └── async_service.rb  # Cola asíncrona para creación de productos
│   └── utils
│       └── response_helper.rb
├── public
│   ├── AUTHORS
│   └── openapi.yaml
```

---

## 🔑 Endpoints

### 1. Autenticación

* **URL:** `/auth`
* **Método:** POST
* **Cuerpo JSON:**

```json
{
  "user": "usuario",
  "password": "contraseña"
}
```

* **Respuesta:**

```json
{
  "token": "<JWT_TOKEN>"
}
```

* Genera un JWT para usar en los endpoints protegidos (`/products`).

---

### 2. Crear producto (asíncrono)

* **URL:** `/products`
* **Método:** POST
* **Headers:** `Authorization: Bearer <JWT_TOKEN>`
* **Cuerpo JSON:**

```json
{
  "name": "Nombre del producto"
}
```

* **Respuesta inmediata:**

```json
{
  "status": "queued"
}
```

> El producto estará disponible **5 segundos después** de la petición, gracias a `$async_service` y `Thread`.

---

### 3. Consultar productos

* **URL:** `/products`
* **Método:** GET
* **Headers:** `Authorization: Bearer <JWT_TOKEN>`
* **Respuesta:**

```json
[
  { "id": 1, "name": "Producto A" },
  { "id": 2, "name": "Producto B" }
]
```

---

### 4. Archivos estáticos

* **`/openapi.yaml`** → especificación OpenAPI. **No cachear**.
* **`/AUTHORS`** → indica autor del proyecto. **Cache 24 horas**.

---

## 🛡 Middlewares

1. **AuthMiddleware**

   * Protege endpoints `/products`.
   * Valida JWT.
   * Permite rutas públicas: `/auth`, `/openapi.yaml`, `/AUTHORS`.

2. **GzipMiddleware**

   * Comprime la respuesta si el cliente solicita `Accept-Encoding: gzip`.
   * Solo comprime respuestas JSON.

---

## 🏗 Ejecución del proyecto

### 1️⃣ Instalar dependencias

```powershell
gem install bundler
bundle install
```

### 2️⃣ Levantar servidor con Rack + Thin

```powershell
rackup -s thin -p 9292
```

> Se ejecuta por defecto en `http://localhost:9292`.

## 🧪 Probando con Postman

1. **Autenticación**

   * POST `http://localhost:9292/auth`
   * Body JSON con user/password
   * Guardar token recibido.

2. **Crear producto**

   * POST `http://localhost:9292/products`
   * Header: `Authorization: Bearer <TOKEN>`
   * Body JSON: `{ "name": "Producto X" }`
   * Respuesta: `{ "status": "queued" }`
   * Esperar 5 segundos y verificar en GET.

3. **Consultar productos**

   * GET `http://localhost:9292/products`
   * Header: `Authorization: Bearer <TOKEN>`
   * Ver productos ya creados.

4. **Archivos estáticos**

   * GET `/openapi.yaml` → obtener OpenAPI
   * GET `/AUTHORS` → obtener autor

> Nota: Postman permite activar `Accept-Encoding: gzip` para probar compresión.

---

## ⚡ Detalles importantes

* Persistencia en memoria → reiniciar servidor limpia productos.
* Creación de productos es **asíncrona** con `Thread` y `Queue`.
* Middleware de compresión GZIP configurable según `Content-Type`.
* JWT simple, con clave `"secret_key"`.

---

## 👤 Autor

**Nombre:** Facundo Tomas Fabbi
**Email:** facundofabbi@hotmail.com

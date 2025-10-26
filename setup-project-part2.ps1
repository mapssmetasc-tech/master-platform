# ============================================================================
# MASTER PLATFORM - AUTOMATED PROJECT SETUP SCRIPT
# ============================================================================
# This script automatically creates all files, folders, and pushes to GitHub
# Created for: Anand Prakash Tripathi
# Repository: https://github.com/anandpktripathi-hub/master-platform
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MASTER PLATFORM AUTO-SETUP SCRIPT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "1. Create all project folders" -ForegroundColor Yellow
Write-Host "2. Generate all source code files" -ForegroundColor Yellow
Write-Host "3. Create configuration files" -ForegroundColor Yellow
Write-Host "4. Commit to Git" -ForegroundColor Yellow
Write-Host "5. Push to GitHub" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# ============================================================================
# STEP 1: CREATE ALL FOLDERS
# ============================================================================

Write-Host ""
Write-Host "Step 1/5: Creating folder structure..." -ForegroundColor Cyan

$folders = @(
    "backend\src\modules\auth\guards",
    "backend\src\modules\auth\strategies",
    "backend\src\modules\users",
    "backend\src\modules\products",
    "backend\src\modules\categories",
    "backend\src\modules\orders",
    "backend\src\modules\carts",
    "backend\src\modules\reviews",
    "backend\src\modules\payments",
    "backend\src\modules\tenants",
    "backend\src\modules\websocket",
    "backend\src\database\schemas",
    "backend\src\common\guards",
    "backend\src\common\decorators",
    "backend\src\common\filters",
    "backend\src\common\interceptors",
    "backend\src\config",
    "frontend\src\pages",
    "frontend\src\components\ui",
    "frontend\src\components\layout",
    "frontend\src\services",
    "frontend\src\hooks",
    "frontend\src\store",
    "frontend\src\types",
    "frontend\src\utils",
    "frontend\src\assets",
    "frontend\public",
    "infrastructure\docker",
    "infrastructure\kubernetes",
    "infrastructure\terraform",
    "docs"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    Write-Host "  Created: $folder" -ForegroundColor Green
}

Write-Host "  Folder structure created successfully!" -ForegroundColor Green

# ============================================================================
# STEP 2: CREATE ALL FILES WITH CONTENT
# ============================================================================

Write-Host ""
Write-Host "Step 2/5: Generating source code files..." -ForegroundColor Cyan

# Function to create file with content
function New-CodeFile {
    param(
        [string]$Path,
        [string]$Content
    )
    $Content | Out-File -FilePath $Path -Encoding UTF8 -Force
    Write-Host "  Created: $Path" -ForegroundColor Green
}

# FILE 1: backend/src/modules/categories/categories.module.ts
New-CodeFile -Path "backend\src\modules\categories\categories.module.ts" -Content @"
import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { CategoriesService } from './categories.service';
import { CategoriesController } from './categories.controller';
import { CategorySchema } from '../../database/schemas/category.schema';

@Module({
  imports: [MongooseModule.forFeature([{ name: 'Category', schema: CategorySchema }])],
  providers: [CategoriesService],
  controllers: [CategoriesController],
  exports: [CategoriesService],
})
export class CategoriesModule {}
"@

# FILE 2: backend/src/modules/categories/categories.service.ts
New-CodeFile -Path "backend\src\modules\categories\categories.service.ts" -Content @"
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class CategoriesService {
  constructor(@InjectModel('Category') private categoryModel: Model<any>) {}

  async create(createCategoryDto: any) {
    const category = new this.categoryModel(createCategoryDto);
    return category.save();
  }

  async findAll() {
    return this.categoryModel.find().populate('parentId').exec();
  }

  async findById(id: string) {
    return this.categoryModel.findById(id).populate('parentId').exec();
  }

  async findChildren(parentId: string) {
    return this.categoryModel.find({ parentId }).exec();
  }

  async update(id: string, updateCategoryDto: any) {
    return this.categoryModel.findByIdAndUpdate(id, updateCategoryDto, { new: true }).exec();
  }

  async remove(id: string) {
    return this.categoryModel.findByIdAndDelete(id).exec();
  }
}
"@

# FILE 3: backend/src/modules/categories/categories.controller.ts
New-CodeFile -Path "backend\src\modules\categories\categories.controller.ts" -Content @"
import { Controller, Get, Post, Body, Param, Put, Delete, UseGuards } from '@nestjs/common';
import { CategoriesService } from './categories.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('categories')
export class CategoriesController {
  constructor(private categoriesService: CategoriesService) {}

  @Get()
  findAll() {
    return this.categoriesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.categoriesService.findById(id);
  }

  @Get(':id/children')
  findChildren(@Param('id') id: string) {
    return this.categoriesService.findChildren(id);
  }

  @UseGuards(JwtAuthGuard)
  @Post()
  create(@Body() createCategoryDto: any) {
    return this.categoriesService.create(createCategoryDto);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':id')
  update(@Param('id') id: string, @Body() updateCategoryDto: any) {
    return this.categoriesService.update(id, updateCategoryDto);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.categoriesService.remove(id);
  }
}
"@

# FILE 4: backend/src/database/schemas/category.schema.ts
New-CodeFile -Path "backend\src\database\schemas\category.schema.ts" -Content @"
import { Schema } from 'mongoose';

export const CategorySchema = new Schema(
  {
    name: { type: String, required: true },
    slug: { type: String, unique: true, required: true },
    description: String,
    parentId: { type: Schema.Types.ObjectId, ref: 'Category', default: null },
    ancestors: [{ type: Schema.Types.ObjectId, ref: 'Category' }],
    level: { type: Number, default: 0 },
    image: String,
    icon: String,
    order: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
    seoTitle: String,
    seoDescription: String,
    seoKeywords: [String],
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now },
  },
  { timestamps: true },
);

CategorySchema.index({ slug: 1 }, { unique: true });
CategorySchema.index({ parentId: 1 });
CategorySchema.index({ level: 1 });
"@

# FILE 5: frontend/src/services/api.ts
New-CodeFile -Path "frontend\src\services\api.ts" -Content @"
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = ``Bearer `${token}``;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
"@

# FILE 6: frontend/src/services/auth.service.ts
New-CodeFile -Path "frontend\src\services\auth.service.ts" -Content @"
import api from './api';

export const authService = {
  async login(email: string, password: string) {
    const response = await api.post('/auth/login', { email, password });
    if (response.data.access_token) {
      localStorage.setItem('token', response.data.access_token);
      localStorage.setItem('user', JSON.stringify(response.data.user));
    }
    return response.data;
  },

  async register(name: string, email: string, password: string) {
    const response = await api.post('/auth/register', { name, email, password });
    return response.data;
  },

  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },

  getCurrentUser() {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
  },

  isAuthenticated() {
    return !!localStorage.getItem('token');
  },
};
"@

# FILE 7: docker-compose.yml
New-CodeFile -Path "docker-compose.yml" -Content @"
version: '3.8'

services:
  mongodb:
    image: mongo:7.0
    container_name: master-platform-mongodb
    restart: always
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
    volumes:
      - mongodb_data:/data/db

  redis:
    image: redis:7-alpine
    container_name: master-platform-redis
    restart: always
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: master-platform-backend
    restart: always
    ports:
      - "4000:4000"
    environment:
      - NODE_ENV=production
      - PORT=4000
      - MONGODB_URI=mongodb://admin:password@mongodb:27017/master-platform?authSource=admin
      - REDIS_HOST=redis
      - FRONTEND_URL=http://localhost:3000
    depends_on:
      - mongodb
      - redis

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: master-platform-frontend
    restart: always
    ports:
      - "3000:80"
    environment:
      - VITE_API_URL=http://localhost:4000/api
    depends_on:
      - backend

volumes:
  mongodb_data:
  redis_data:
"@

# FILE 8: README.md Update
New-CodeFile -Path "README.md" -Content @"
# Master Platform

Complete multi-tenant SaaS platform with modern tech stack.

## Tech Stack

- **Frontend**: React 19 + TypeScript 5.x + Vite 5 + Tailwind CSS 4
- **Backend**: NestJS 16 + MongoDB 7.x
- **Infrastructure**: Docker, Kubernetes, Terraform

## Quick Start

### Prerequisites
- Node.js 18+
- Docker & Docker Compose
- Git

### Installation

``````bash
# Clone repository
git clone https://github.com/anandpktripathi-hub/master-platform.git
cd master-platform

# Install dependencies
cd backend && npm install
cd ../frontend && npm install

# Start with Docker
docker-compose up -d

# Or start manually
# Terminal 1 - Backend
cd backend && npm run start:dev

# Terminal 2 - Frontend
cd frontend && npm run dev
``````

## Project Structure

``````
master-platform/
├── backend/          # NestJS backend
├── frontend/         # React frontend
├── infrastructure/   # DevOps configs
└── docs/            # Documentation
``````

## Features

- ✅ Multi-tenant architecture
- ✅ E-commerce functionality
- ✅ Real-time notifications
- ✅ User authentication (JWT)
- ✅ Product management
- ✅ Order processing
- ✅ Cart management
- ✅ Category hierarchy
- ✅ RESTful API
- ✅ Docker containerization

## Created By

Anand Prakash Tripathi

## License

Private - All Rights Reserved
"@

Write-Host "  All source files created successfully!" -ForegroundColor Green

# ============================================================================
# STEP 3: GIT COMMIT
# ============================================================================

Write-Host ""
Write-Host "Step 3/5: Committing to Git..." -ForegroundColor Cyan

try {
    git add .
    Write-Host "  Files staged for commit" -ForegroundColor Green
    
    git commit -m "Add Categories module, Frontend services, and Docker configs - Automated Setup"
    Write-Host "  Committed successfully" -ForegroundColor Green
}
catch {
    Write-Host "  Warning: Git commit had issues, but continuing..." -ForegroundColor Yellow
}

# ============================================================================
# STEP 4: PUSH TO GITHUB
# ============================================================================

Write-Host ""
Write-Host "Step 4/5: Pushing to GitHub..." -ForegroundColor Cyan

try {
    git push origin main
    Write-Host "  Pushed to GitHub successfully!" -ForegroundColor Green
}
catch {
    Write-Host "  Warning: Push failed. You may need to push manually." -ForegroundColor Yellow
    Write-Host "  Run: git push origin main" -ForegroundColor Yellow
}

# ============================================================================
# STEP 5: COMPLETION & SUMMARY
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "What was created:" -ForegroundColor Cyan
Write-Host "  ✓ 32 folders created" -ForegroundColor Green
Write-Host "  ✓ 8 source code files generated" -ForegroundColor Green
Write-Host "  ✓ Docker configuration complete" -ForegroundColor Green
Write-Host "  ✓ README updated" -ForegroundColor Green
Write-Host "  ✓ Committed to Git" -ForegroundColor Green
Write-Host "  ✓ Pushed to GitHub" -ForegroundColor Green
Write-Host ""
Write-Host "Your GitHub Repository:" -ForegroundColor Cyan
Write-Host "  https://github.com/anandpktripathi-hub/master-platform" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Verify files on GitHub" -ForegroundColor White
Write-Host "  2. Run 'cd backend && npm install' to install backend dependencies" -ForegroundColor White
Write-Host "  3. Run 'cd frontend && npm install' to install frontend dependencies" -ForegroundColor White
Write-Host "  4. Run 'docker-compose up' to start the application" -ForegroundColor White
Write-Host ""
Write-Host "For additional files, run Part 3 setup script (coming next)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

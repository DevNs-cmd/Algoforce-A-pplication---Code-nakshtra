import 'package:dio/dio.dart';

class NexusApiService {
  NexusApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  final Dio _dio;

  Future<String> generateCode(
    String prompt, {
    String framework = 'React',
    bool includeComments = true,
    int maxLines = 60,
    String codeStyle = 'hooks-first',
  }) async {
    final context = _frameworkContext(framework);
    final commentRule = includeComments
        ? 'Include concise comments only where they clarify behavior.'
        : 'Do not include comments except the filename header.';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: const {
            'Content-Type': 'application/json',
            'anthropic-version': '2023-06-01',
          },
        ),
        data: {
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1000,
          'messages': [
            {
              'role': 'user',
              'content':
                  'You are Nexus AI, AlgoForce\\u0027s vibe coding tool. $context User prompt: "$prompt". $commentRule Use a $codeStyle code style. Respond ONLY with realistic product code under $maxLines lines. Start with a comment filename header. No explanation. No markdown fences. Just the code.',
            },
          ],
        },
      );
      final data = response.data;
      final content = data?['content'];
      if (content is List && content.isNotEmpty) {
        final first = content.first;
        if (first is Map && first['text'] is String) {
          return first['text'] as String;
        }
      }
      return _fallback(prompt, framework: framework);
    } on DioException {
      return _fallback(prompt, framework: framework);
    } catch (_) {
      return _fallback(prompt, framework: framework);
    }
  }

  String _frameworkContext(String framework) {
    return switch (framework) {
      'Vue' => 'Generate Vue 3 Composition API single-file component code.',
      'Svelte' => 'Generate Svelte component code.',
      'Next.js' => 'Generate Next.js 14 App Router client component code.',
      'Plain HTML' =>
        'Generate one plain HTML file with inline CSS and JavaScript.',
      _ => 'Generate React 18 hooks and functional component code.',
    };
  }

  String _fallback(String prompt, {required String framework}) {
    final title = prompt.trim().isEmpty
        ? 'AlgoForce Build'
        : prompt.trim().split(' ').take(5).join(' ');
    if (framework == 'Plain HTML') {
      return '''// algoforce-launch.html
<main class="launch">
  <section>
    <p>Built by Nexus AI</p>
    <h1>$title</h1>
    <p>Train builders, validate founders, and launch revenue-ready products from one operating loop.</p>
    <form onsubmit="event.preventDefault(); document.querySelector('#status').textContent='Founder signal captured. Studio review starts next.'">
      <input type="email" placeholder="founder@company.com" required />
      <button>Join waitlist</button>
    </form>
    <strong id="status"></strong>
  </section>
</main>
<style>
  body { margin: 0; font-family: Inter, system-ui; background: #fafaf9; color: #0f172a; }
  .launch { min-height: 100vh; display: grid; place-items: center; padding: 48px; }
  section { max-width: 760px; }
  p:first-child { color: #7c3aed; font-weight: 800; }
  h1 { font-size: 56px; line-height: .95; }
  input, button { border-radius: 14px; padding: 14px 16px; border: 1px solid #d6d3d1; }
  button { background: #7c3aed; color: white; font-weight: 800; }
</style>
''';
    }
    return '''// algoforce-launch.jsx
import React, { useState } from "react";

export default function AlgoForceLaunch() {
  const [email, setEmail] = useState("");
  const [joined, setJoined] = useState(false);

  function submitLead(event) {
    event.preventDefault();
    if (!email.includes("@")) return;
    setJoined(true);
  }

  return (
    <main className="min-h-screen bg-stone-50 text-slate-950">
      <section className="mx-auto max-w-5xl px-6 py-20">
        <p className="text-sm font-semibold text-violet-600">Built by Nexus AI</p>
        <h1 className="mt-3 text-5xl font-black tracking-tight">$title</h1>
        <p className="mt-5 max-w-2xl text-lg text-stone-600">
          Train builders, validate founders, and launch revenue-ready products from one operating loop.
        </p>
        <form onSubmit={submitLead} className="mt-8 flex gap-3">
          <input value={email} onChange={(e) => setEmail(e.target.value)} placeholder="founder@company.com" className="rounded-xl border px-4 py-3" />
          <button className="rounded-xl bg-violet-600 px-5 py-3 font-bold text-white">Join waitlist</button>
        </form>
        {joined && <p className="mt-4 text-emerald-700">Founder signal captured. Studio review starts next.</p>}
      </section>
    </main>
  );
}
''';
  }
}
